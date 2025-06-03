import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { and, eq } from "drizzle-orm";
import { db } from "@/db/index.ts";
import { commentsTable, notificationsTable } from "@/db/schema.ts";
import { pusher } from "@/utils/pusher.ts";
import {
  addCommentSchema,
  editCommentSchema,
} from "@/schema/services/comment.ts";
import { offersTable } from "@/db/schema.ts";

const app = new Hono();

app.post(
  "/",
  authRequired,
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 50,
  }),
  zValidator(
    "json",
    addCommentSchema,
  ),
  async (c) => {
    const { content, offerId } = c.req.valid("json");
    const session = c.get("session");

    const offer = await db.query.offersTable.findFirst({
      where: eq(offersTable.id, offerId),
    });

    if (!offer) {
      return c.json({ message: "Offer not found" }, 404);
    }

    try {
      const [comment] = await db.insert(commentsTable).values({
        offerId,
        userId: session.user.id,
        content,
      }).returning({
        id: commentsTable.id,
        offerId: commentsTable.offerId,
        content: commentsTable.content,
        createdAt: commentsTable.createdAt,
      });

      const completeComment = {
        ...comment,
        user: {
          id: session.user.id,
          username: session.user.username,
        },
      };

      pusher.trigger(
        `public-request-${offer.requestId}`,
        "new-offer-comment",
        completeComment,
      ).catch((e) => {
        console.error("Async Pusher trigger error: ", e);
      });

      if (offer.userId !== session.user.id) {
        const notification = await db.insert(notificationsTable).values({
          type: "NEW_OFFER_COMMENT",
          relatedRequestId: offer.requestId,
          relatedOfferId: offer.id,
          relatedUserId: session.user.id,
          userId: offer.userId,
        }).returning();

        pusher.trigger(
          `private-user-${offer.userId}`,
          "new-notification",
          {
            ...notification[0],
            relatedUser: {
              name: session.user.name,
            },
            relatedOffer: {
              content: offer.content,
            },
          },
        ).catch((e) => {
          console.error("Async Pusher trigger error: ", e);
        });
      }

      return c.json({
        message: "Comment added successfully",
      });
    } catch (e) {
      console.error(e);

      return c.json(
        { message: "Something went wrong while saving the comment" },
        500,
      );
    }
  },
);

app.put(
  "/:commentId",
  authRequired,
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 50,
  }),
  zValidator(
    "param",
    z.object({
      commentId: z
        .string()
        .refine(
          (value) => !isNaN(Number(value)),
          "commentId must be a valid number",
        )
        .transform((value) => Number(value)),
    }),
  ),
  zValidator(
    "json",
    editCommentSchema,
  ),
  async (c) => {
    const { commentId } = c.req.valid("param");
    const { content } = c.req.valid("json");
    const session = c.get("session");

    const comment = await db.query.commentsTable.findFirst({
      where: and(
        eq(commentsTable.id, commentId),
        eq(commentsTable.userId, session.user.id),
      ),
      with: {
        offer: {
          columns: {
            id: true,
            requestId: true,
          },
        },
      },
    });

    if (!comment) {
      return c.json({ message: "Comment not found" }, 404);
    }

    await db.update(commentsTable)
      .set({
        content,
        edited: true,
      })
      .where(and(
        eq(commentsTable.id, commentId),
        eq(commentsTable.userId, session.user.id),
      ));

    if (comment.offer) {
      pusher.trigger(
        `public-request-${comment.offer.requestId}`,
        "update-offer-comment",
        {
          offerId: comment.offer.id,
          commentId,
          content,
        },
      ).catch((e) => {
        console.error("Async Pusher trigger error: ", e);
      });
    }

    return c.json({
      message: "Comment updated successfully",
    });
  },
);

app.delete(
  "/:commentId",
  authRequired,
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 50,
  }),
  zValidator(
    "param",
    z.object({
      commentId: z
        .string()
        .refine(
          (value) => !isNaN(Number(value)),
          "commentId must be a valid number",
        )
        .transform((value) => Number(value)),
    }),
  ),
  async (c) => {
    const { commentId } = c.req.valid("param");
    const session = c.get("session");

    const comment = await db.query.commentsTable.findFirst({
      where: and(
        eq(commentsTable.id, commentId),
        eq(commentsTable.userId, session.user.id),
      ),
      with: {
        offer: {
          columns: {
            id: true,
            requestId: true,
          },
        },
      },
    });

    if (!comment) {
      return c.json({ message: "Comment not found" }, 404);
    }

    await db.delete(commentsTable)
      .where(and(
        eq(commentsTable.id, commentId),
        eq(commentsTable.userId, session.user.id),
      ));

    if (comment.offer) {
      pusher.trigger(
        `public-request-${comment.offer.requestId}`,
        "delete-offer-comment",
        {
          offerId: comment.offer.id,
          commentId,
        },
      ).catch((e) => {
        console.error("Async Pusher trigger error: ", e);
      });
    }

    return c.json({
      message: "Comment deleted successfully",
    });
  },
);

export default app;
