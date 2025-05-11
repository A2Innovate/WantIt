import { Hono } from "hono";
import { db } from "@/db/index.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { ilike } from "drizzle-orm";
import { requestsTable } from "@/db/schema.ts";
import { authRequired } from "@/middleware/auth.ts";

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
      },
    });

    return c.json(requests);
  },
);

app.post(
  "/create",
  authRequired,
  zValidator(
    "json",
    z.object({
      content: z.string(),
    }),
  ),
  async (c) => {
    const session = c.get("session");

    const request = await db.insert(requestsTable).values({
      content: c.req.valid("json").content,
      userId: session.user.id,
    }).returning();

    return c.json(request);
  },
);

export default app;
