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
import { deleteFile, deleteRecursive, uploadFileBuffer } from "@/utils/s3.ts";
import { generateUniqueOfferImageUUID } from "@/utils/generate.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";
import { ImagePipelineInputs } from "@huggingface/transformers";
import { pusher } from "@/utils/pusher.ts";

import sharp from "sharp";

import { pipeline } from "@huggingface/transformers";

const app = new Hono();

let _pipe: ImagePipelineInputs | null = null;
const NSFW_THRESHOLD = 0.6;
const NSFW_CATEGORIES = ["porn", "hentai", "sexy"];

async function getPipe() {
  if (!_pipe) {
    try {
      _pipe = await pipeline(
        "image-classification",
        "onnx-community/nsfw-image-detector-ONNX",
      );
    } catch (error) {
      console.error("Failed to load NSFW model:", error);
      throw new Error("NSFW detection service unavailable");
    }
  }
  return _pipe;
}

app.get(
  "/",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 1000,
  }),
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
        currency: true,
        budget: true,
      },
    });

    return c.json(requests);
  },
);

app.get(
  "/:requestId",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 250,
  }),
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
        currency: true,
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
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 30,
  }),
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
      const [offer] = await db.insert(offersTable).values({
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
        requestId: offersTable.requestId,
      });

      const completeOffer = {
        ...offer,
        images: [],
        user: {
          id: session.user.id,
          name: session.user.name,
        },
      };

      pusher.trigger(
        `public-request-${requestId}`,
        "new-offer",
        completeOffer,
      ).catch((e) => {
        console.error("Async Pusher trigger error: ", e);
      });

      return c.json(offer);
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
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 300,
  }),
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
    let offerImages;
    try {
      for (const image of images) {
        const imageBuffer = await image.arrayBuffer();
        const sharpImage = sharp(imageBuffer);

        const pipe = await getPipe();
        const prediction = await pipe(image);
        for (const result of prediction) {
          if (
            result.score > NSFW_THRESHOLD &&
            NSFW_CATEGORIES.includes(result.label)
          ) {
            throw new Error("Image contains NSFW content");
          }
        }

        const imageName = await generateUniqueOfferImageUUID(offerId) + ".webp";

        imageNames.push(imageName);
        await uploadFileBuffer({
          buffer: await sharpImage.webp({ quality: 80 }).toBuffer(),
          key: `request/${requestId}/offer/${offerId}/images/${imageName}`,
        });
      }

      offerImages = await db.insert(offerImagesTable).values(
        imageNames.map((imageName) => ({
          offerId,
          name: imageName,
        })),
      ).returning();
    } catch (e) {
      for (const imageName of imageNames) {
        await deleteFile(
          `request/${requestId}/offer/${offerId}/images/${imageName}`,
        );
      }

      if (e instanceof Error && e.message === "Image contains NSFW content") {
        return c.json(
          { message: e.message },
          400,
        );
      }

      return c.json(
        { message: "Something went wrong while uploading images" },
        500,
      );
    }

    pusher.trigger(
      `public-request-${requestId}`,
      "update-offer-images",
      {
        offerId,
        images: offerImages.map((image) => image.name),
      },
    ).catch((e) => {
      console.error("Async Pusher trigger error: ", e);
    });

    return c.json(offerImages);
  },
);

app.post(
  "/",
  authRequired,
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 15,
  }),
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
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 30,
  }),
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

    pusher.trigger(
      `public-request-${requestId}`,
      "update-request",
      request[0],
    ).catch((e) => {
      console.error("Async Pusher trigger error: ", e);
    });

    return c.json(request[0]);
  },
);

app.delete(
  "/:requestId",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator(
    "param",
    requestByIdSchema,
  ),
  async (c) => {
    const { requestId } = c.req.valid("param");
    const session = c.get("session");

    const request = await db.query.requestsTable.findFirst({
      where: and(
        eq(requestsTable.id, requestId),
        eq(requestsTable.userId, session.user.id),
      ),
    });

    if (!request) {
      return c.json({ message: "Request not found" }, 404);
    }

    await deleteRecursive(`request/${requestId}`);

    await db.delete(requestsTable)
      .where(and(
        eq(requestsTable.id, requestId),
        eq(requestsTable.userId, session.user.id),
      ));

    pusher.trigger(
      `public-request-${requestId}`,
      "delete-request",
      requestId,
    ).catch((e) => {
      console.error("Async Pusher trigger error: ", e);
    });

    return c.json({
      message: "Request deleted successfully",
    });
  },
);

export default app;
