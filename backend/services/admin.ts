import { Hono } from "hono";
import { adminRequired } from "@/middleware/auth.ts";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { gt, sql } from "drizzle-orm";
import { requestsTable, usersTable } from "@/db/schema.ts";
import { offersTable } from "@/db/schema.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";

const app = new Hono();

app.use(authRequired, adminRequired);

app.get("/stats", async (c) => {
  const [users] = await db.select({
    count: sql<number>`count(*)`,
  }).from(usersTable);

  const [offers] = await db.select({
    count: sql<number>`count(*)`,
  }).from(offersTable);

  const [requests] = await db.select({
    count: sql<number>`count(*)`,
  }).from(requestsTable);

  return c.json({ users, offers, requests });
});

app.get(
  "/stats/users",
  zValidator(
    "query",
    z.object({
      days: z.string().refine(
        (value) => !isNaN(Number(value)),
        "days must be a valid number",
      ).transform((value) => Number(value)).pipe(
        z.number().min(1).max(365).default(30),
      ),
    }),
  ),
  async (c) => {
    const { days } = c.req.valid("query");

    const users = await db.query.usersTable.findMany({
      where: gt(
        usersTable.createdAt,
        new Date(Date.now() - days * 24 * 60 * 60 * 1000),
      ),
      columns: {
        createdAt: true,
      },
    });

    const day = [];
    const count = [];

    const dateFormat = new Intl.DateTimeFormat("en-US", {
      month: "2-digit",
      day: "2-digit",
    });

    for (let i = 0; i < days; i++) {
      const now = new Date();
      now.setDate(now.getDate() - i);
      const date = dateFormat.format(now);

      day.push(date);
      count.push(
        users.filter((user) => dateFormat.format(user.createdAt) === date)
          .length,
      );
    }

    return c.json({ day, count });
  },
);

export default app;
