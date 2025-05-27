import { Hono } from "hono";
import { db } from "@/db/index.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { and, eq, gt, ilike, cosineDistance, desc, sql } from "drizzle-orm";
import { offerImagesTable, offersTable, requestsTable, usersTable } from "@/db/schema.ts";
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
import { detectNSFW } from "@/utils/ai/nsfw.ts";
import { getEmbeddings } from "@/utils/ai/similarity.ts";

import sharp from "sharp";


const app = new Hono();

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

    // If no search query, return recent items (fallback)
    if (!query.content) {
      const requests = await db.query.requestsTable.findMany({
        limit: 5,
        orderBy: (t, { desc }) => desc(t.id),
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
    }

    
    // const similarity = sql<number>`1 - (${cosineDistance(requestsTable.embedding, embedding)})`;



    const firstWord = await getEmbeddings("iPhone 14");
    const secondWord = await getEmbeddings("iphne 14");
    // console.log(potatoEmbeddingRaw[0].data)
    // console.log(strawberryEmbeddingRaw[0].data)

    function cosineSimilarity(a: number[], b: number[]) {
      const dotProduct = a.reduce((sum, ai, i) => sum + ai * b[i], 0);
      const normA = Math.sqrt(a.reduce((sum, ai) => sum + ai * ai, 0));
      const normB = Math.sqrt(b.reduce((sum, bi) => sum + bi * bi, 0));
      return dotProduct / (normA * normB);
    }
    console.log(cosineSimilarity(firstWord[0].data, secondWord[0].data))
    //consinedistance htme
    // console.log(cosineDistance(samsung, iphone));

    // const similarGuides = await db.query.requestsTable.findMany({
    //   columns: {
    //     id: true,
    //     content: true,
    //     budget: true,
    //   },
    //   extras: {
    //     // similarity,
    //   },
    //   with: {
    //     user: {
    //       columns: {
    //         id: true,
    //         name: true,
    //         email: true,
    //       },
    //     },
    //   },
    //   where: gt(similarity, 0.7),
    //   orderBy: desc(similarity),
    //   limit: 4,
    // });
  


   
    // const results = await db
    // .select({
    //   id: requestsTable.id,
    //   content: requestsTable.content,
    //   budget: requestsTable.budget,
    //   similarity,
    //   user: {
    //     id: usersTable.id,
    //     name: usersTable.name,
    //     email: usersTable.email,
    //   },
    // })
    // .from(requestsTable)
    // .leftJoin(usersTable, eq(requestsTable.userId, usersTable.id))
    // .where(gt(similarity, 0.7))
    // .orderBy(desc(similarity))
    // .limit(4);

  // const similarGuidesResponse = results.map((result) => ({
     
  //     id: result.id,
  //     content: result.content,
  //     budget: result.budget,
  //     user: result.user,
  //     similarity: result.similarity,

  // }));
  //   // Map results to match the desired structure

    return c.json({})
      
    // }));
  

    // console.log(similarGuides);

  }
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

        const prediction = await detectNSFW(image);
        if (prediction) {
          throw new Error("Image contains NSFW content");
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
      embedding: await getEmbeddings(content),
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

    return c.json({
      message: "Request deleted successfully",
    });
  },
);

export default app;
