import { Hono } from "hono";
import { db } from "@/db/index.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { ilike } from "drizzle-orm";
import { requestsTable } from "@/db/schema.ts";

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

export default app;
