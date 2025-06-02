import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";
import { db } from "@/db/index.ts";
import { eq } from "drizzle-orm";
import { notificationsTable } from "@/db/schema.ts";

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
    });

    return c.json(notifications);
  },
);

export default app;
