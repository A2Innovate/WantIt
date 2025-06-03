import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";
import { db } from "@/db/index.ts";
import { and, eq } from "drizzle-orm";
import { notificationsTable } from "@/db/schema.ts";
import { zValidator } from "@hono/zod-validator";
import { pusher } from "@/utils/pusher.ts";
import { notificationByIdSchema } from "@/schema/services/notification.ts";

const app = new Hono();

app.get(
  "/",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  async (c) => {
    const session = c.get("session");

    const notifications = await db.query.notificationsTable.findMany({
      where: eq(notificationsTable.userId, session.userId),
      columns: {
        userId: false,
      },
      with: {
        relatedRequest: {
          columns: {
            content: true,
          },
        },
        relatedOffer: {
          columns: {
            content: true,
          },
        },
        relatedUser: {
          columns: {
            name: true,
          },
        },
      },
    });

    return c.json(notifications);
  },
);

app.post(
  "/:notificationId/read",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  zValidator(
    "param",
    notificationByIdSchema,
  ),
  async (c) => {
    const session = c.get("session");
    const { notificationId } = c.req.valid("param");

    await db.update(notificationsTable).set({
      read: true,
    }).where(
      and(
        eq(notificationsTable.id, notificationId),
        eq(notificationsTable.userId, session.userId),
      ),
    );

    pusher.trigger(
      `private-user-${session.userId}`,
      "notification-read",
      {
        notificationId,
      },
    ).catch((e) => {
      console.error("Async Pusher trigger error: ", e);
    });

    return c.json({
      message: "Notification marked as read",
    });
  },
);

app.delete(
  "/:notificationId",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  zValidator(
    "param",
    notificationByIdSchema,
  ),
  async (c) => {
    const session = c.get("session");
    const { notificationId } = c.req.valid("param");

    await db.delete(notificationsTable).where(
      and(
        eq(notificationsTable.id, notificationId),
        eq(notificationsTable.userId, session.userId),
      ),
    );

    pusher.trigger(
      `private-user-${session.userId}`,
      "notification-delete",
      {
        notificationId,
      },
    ).catch((e) => {
      console.error("Async Pusher trigger error: ", e);
    });

    return c.json({
      message: "Notification deleted",
    });
  },
);

app.post(
  "/clear",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  async (c) => {
    const session = c.get("session");

    await db.delete(notificationsTable).where(
      eq(notificationsTable.userId, session.userId),
    );

    pusher.trigger(
      `private-user-${session.userId}`,
      "notification-clear",
      {},
    ).catch((e) => {
      console.error("Async Pusher trigger error: ", e);
    });

    return c.json({
      message: "Notifications cleared",
    });
  },
);

export default app;
