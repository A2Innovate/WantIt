import { Hono } from "hono";
import { db } from "@/db/index.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { and, eq, ilike } from "drizzle-orm";
import { requestsTable } from "@/db/schema.ts";
import { authRequired } from "@/middleware/auth.ts";
import {
  createRequestSchema,
  editRequestSchema,
  requestByIdSchema,
} from "@/schema/services/request.ts";

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
    return c.json(request[0]);
  },
);

export default app;
