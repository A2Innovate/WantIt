import { Hono } from "hono";
import { db } from "@/db/index.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { and, eq, ilike } from "drizzle-orm";
import { offerImagesTable, offersTable, requestsTable } from "@/db/schema.ts";
import { authRequired } from "@/middleware/auth.ts";
import {
  createOfferSchema,
  createRequestSchema,
  editRequestSchema,
  requestByIdSchema,
} from "@/schema/services/request.ts";
import { uploadFile } from "@/utils/s3.ts";
import { generateUniqueOfferImageUUID } from "@/utils/generate.ts";

const app = new Hono();

app.get(
  "/",
  zValidator(
    "query",
    z.object({
      content: z.string().optional(),
    }),
  ),
  async (c) => {
    const query = c.req.valid("query");

    const requests = await db.query.requestsTable.findMany({
      where: ilike(requestsTable.content, `%${query.content}%`),
      with: {
        user: {
          columns: {
            id: true,
            name: true,
          },
        },
      },
      columns: {
        id: true,
        content: true,
        budget: true,
      },
    });

    return c.json(requests);
  },
);

app.get(
  "/:requestId",
  zValidator(
    "param",
    requestByIdSchema,
  ),
  async (c) => {
    const { requestId } = c.req.valid("param");

    const request = await db.query.requestsTable.findFirst({
      where: eq(requestsTable.id, requestId),
      with: {
        user: {
          columns: {
            id: true,
            name: true,
          },
        },
        offers: {
          columns: {
            id: true,
            content: true,
            requestId: true,
            price: true,
            negotiation: true,
          },
          with: {
            user: {
              columns: {
                id: true,
                name: true,
              },
            },
            images: {
              columns: {
                name: true,
              },
            },
          },
        },
      },
      columns: {
        id: true,
        content: true,
        budget: true,
      },
    });

    if (!request) {
      return c.json({ message: "Request not found" }, 404);
    }

    return c.json(request);
  },
);

app.post(
  "/:requestId/offer",
  authRequired,
  zValidator(
    "param",
    requestByIdSchema,
  ),
  zValidator(
    "json",
    createOfferSchema,
  ),
  async (c) => {
    const { requestId } = c.req.valid("param");
    const { content, price, negotiation } = c.req.valid("json");
    const session = c.get("session");

    try {
      const offer = await db.insert(offersTable).values({
        requestId,
        content,
        price,
        negotiation,
        userId: session.user.id,
      }).returning({
        id: offersTable.id,
        content: offersTable.content,
        price: offersTable.price,
        negotiation: offersTable.negotiation,
      });

      return c.json(offer[0]);
    } catch (e) {
      if (
        e instanceof Error &&
        e.message.includes("offers_requestId_requests_id_fk")
      ) {
        return c.json({ message: "Request not found" }, 404);
      }

      return c.json(
        { message: "Something went wrong while creating offer" },
        500,
      );
    }
  },
);

app.post(
  "/:requestId/offer/:offerId/image",
  authRequired,
  zValidator(
    "param",
    z.object({
      requestId: z
        .string()
        .refine(
          (value) => !isNaN(Number(value)),
          "requestId must be a valid number",
        )
        .transform((value) => Number(value)),
      offerId: z
        .string()
        .refine(
          (value) => !isNaN(Number(value)),
          "offerId must be a valid number",
        )
        .transform((value) => Number(value)),
    }),
  ),
  zValidator(
    "form",
    z.object({
      "images[]": z.array(
        z.instanceof(File)
          .refine(
            (file) => file.size > 0,
            "Uploaded image cannot be empty.",
          )
          .refine(
            (file) => file.size < 1024 * 1024 * 5,
            "Image must be smaller than 5MB.",
          )
          .refine(
            (file) => file.type.startsWith("image/"),
            "File must be an image (e.g., image/jpeg, image/png).",
          ),
      )
        .min(1, "You must upload at least one image.")
        .max(10, "You can upload up to 10 images."),
    }),
  ),
  async (c) => {
    const { requestId, offerId } = c.req.valid("param");
    const { "images[]": images } = c.req.valid("form");
    const session = c.get("session");

    const offer = await db.query.offersTable.findFirst({
      where: and(
        eq(offersTable.id, offerId),
        eq(offersTable.requestId, requestId),
        eq(offersTable.userId, session.user.id),
      ),
      with: {
        images: true,
      },
    });

    if (!offer) {
      return c.json({ message: "Offer not found" }, 404);
    }

    if (offer.images.length + images.length > 10) {
      return c.json({ message: "One offer can have up to 10 images." }, 400);
    }

    const imageNames: string[] = [];
    for (const image of images) {
      const imageName = await generateUniqueOfferImageUUID(requestId, offerId) +
        "." + image.name.split(".").pop();
      imageNames.push(imageName);
      await uploadFile({
        file: image,
        key: `request/${requestId}/offer/${offerId}/images/${imageName}`,
      });
    }

    const offerImages = await db.insert(offerImagesTable).values(
      imageNames.map((imageName) => ({
        offerId,
        name: imageName,
      })),
    ).returning();

    return c.json(offerImages);
  },
);

app.post(
  "/",
  authRequired,
  zValidator(
    "json",
    createRequestSchema,
  ),
  async (c) => {
    const { content, budget } = c.req.valid("json");
    const session = c.get("session");

    const request = await db.insert(requestsTable).values({
      content,
      userId: session.user.id,
      budget,
    }).returning();

    return c.json(request[0]);
  },
);

app.put(
  "/:requestId",
  authRequired,
  zValidator(
    "param",
    requestByIdSchema,
  ),
  zValidator(
    "json",
    editRequestSchema,
  ),
  async (c) => {
    const { requestId } = c.req.valid("param");
    const { content, budget } = c.req.valid("json");
    const session = c.get("session");

    const request = await db.update(requestsTable)
      .set({
        content,
        budget,
      })
      .where(and(
        eq(requestsTable.id, requestId),
        eq(requestsTable.userId, session.user.id),
      ))
      .returning();

    if (!request[0]) {
      return c.json({ message: "Request not found" }, 404);
    }

    return c.json(request[0]);
  },
);

export default app;
