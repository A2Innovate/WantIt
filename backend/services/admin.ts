import { Hono } from "hono";
import { adminRequired } from "@/middleware/auth.ts";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { desc, gt, sql } from "drizzle-orm";
import { logsTable, requestsTable, usersTable } from "@/db/schema.ts";
import { offersTable } from "@/db/schema.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { client } from "@/utils/redis.ts";

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

  return c.json({
    users: users.count,
    offers: offers.count,
    requests: requests.count,
  });
});

app.get("/stats/ratelimit/endpoints", async (c) => {
  const data = await client.keys("stats:ratelimit:exceeded:*");

  const endpoints = [];
  const count = [];

  for (const key of data) {
    const [, , , method, ...routeParts] = key.split(":");
    const timestamps = await client.zrangebyscore(key, 0, Date.now());

    endpoints.push(method + ":" + routeParts.join(":"));
    count.push(timestamps.length);
  }

  return c.json({ endpoints, count });
});

app.get(
  "/stats/:type",
  zValidator(
    "param",
    z.object({ type: z.enum(["users", "offers", "requests"]) }),
  ),
  zValidator(
    "query",
    z.object({
      days: z.string().refine(
        (value) => !isNaN(Number(value)),
        "days must be a valid number",
      ).transform((value) => Number(value)).optional().pipe(
        z.number().min(1).max(365).default(30),
      ),
      cache: z.string().optional().default("true").transform((value) =>
        value === "true"
      ),
    }),
  ),
  async (c) => {
    const { days, cache } = c.req.valid("query");
    const { type } = c.req.valid("param");

    const cached = await client.get(`stats:${type}:${days}`);

    if (cached && cache) {
      return c.json(JSON.parse(cached));
    }

    let tableSchema;
    let dataFetcher;

    if (type === "users") {
      tableSchema = usersTable;
      dataFetcher = db.query.usersTable;
    } else if (type === "offers") {
      tableSchema = offersTable;
      dataFetcher = db.query.offersTable;
    } else if (type === "requests") {
      tableSchema = requestsTable;
      dataFetcher = db.query.requestsTable;
    } else {
      return c.json({ error: "Invalid type" }, 400);
    }

    const data = await dataFetcher.findMany({
      where: gt(
        tableSchema.createdAt,
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

    for (let i = days - 1; i >= 0; i--) {
      const now = new Date();
      now.setDate(now.getDate() - i);
      const date = dateFormat.format(now);

      day.push(date);
      count.push(
        data.filter((item) => dateFormat.format(item.createdAt) === date)
          .length,
      );
    }

    client.set(`stats:${type}:${days}`, JSON.stringify({ day, count })).catch(
      (e) => {
        console.error("Async Redis set error: ", e);
      },
    );

    client.expire(`stats:${type}:${days}`, 60 * 30).catch((e) => {
      console.error("Async Redis expire error: ", e);
    });

    return c.json({ day, count });
  },
);

app.get("/logs", async (c) => {
  const logs = await db.query.logsTable.findMany({
    orderBy: desc(logsTable.id),
    limit: 50,
  });

  return c.json(logs);
});

export default app;
