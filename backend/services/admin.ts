import { Hono } from "hono";
import { adminRequired } from "@/middleware/auth.ts";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { asc, desc, eq, gt, ilike, or, sql } from "drizzle-orm";
import { logsTable, requestsTable, usersTable } from "@/db/schema.ts";
import { offersTable } from "@/db/schema.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { client } from "@/utils/redis.ts";
import { listFiles } from "@/utils/s3.ts";
import { pusher } from "../utils/pusher.ts";
import { getUserByIdSchema } from "../schema/services/user.ts";

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

app.get(
  "/logs",
  zValidator(
    "query",
    z.object({
      limit: z.string().refine(
        (value) => !isNaN(Number(value)),
        "limit must be a valid number",
      ).transform((value) => Number(value)).optional().pipe(
        z.number().min(1).max(100).default(50),
      ),
      offset: z.string().refine(
        (value) => !isNaN(Number(value)),
        "offset must be a valid number",
      ).transform((value) => Number(value)).optional().pipe(
        z.number().min(0).default(0),
      ),
    }),
  ),
  async (c) => {
    const { limit, offset } = c.req.valid("query");

    const logs = await db.query.logsTable.findMany({
      with: {
        user: {
          columns: {
            id: true,
            username: true,
            name: true,
          },
        },
      },
      orderBy: desc(logsTable.id),
      limit,
      offset,
    });

    return c.json(logs);
  },
);

app.post("/integrity/s3-db", async (c) => {
  await pusher.trigger("private-admin-options", "integrity-check-log", {
    message: "Listing S3 files...",
  });

  const files = await listFiles("request/");

  await pusher.trigger("private-admin-options", "integrity-check-log", {
    message: `Found ${files.length} files`,
  });

  await pusher.trigger("private-admin-options", "integrity-check-log", {
    message: "Listing database offers...",
  });

  const offers = await db.query.offersTable.findMany({
    columns: {
      id: true,
      requestId: true,
    },
    with: {
      images: {
        columns: {
          name: true,
        },
      },
    },
  });

  await pusher.trigger("private-admin-options", "integrity-check-log", {
    message: `Found ${offers.length} offers`,
  });

  const notInDb = [];
  const notInFiles = [];

  await pusher.trigger("private-admin-options", "integrity-check-log", {
    message: "Checking files...",
  });

  for (const file of files) {
    const offerId = Number(file.split("/")[3]);
    const imageName = file.split("/")[5];

    const offer = offers.find((offer) => offer.id === offerId);

    if (!offer) {
      notInDb.push(file);
      await pusher.trigger("private-admin-options", "integrity-check-log", {
        message: `Unknown file ${file} found in S3`,
      });
      continue;
    }

    if (!offer.images.some((image) => image.name === imageName)) {
      notInDb.push(file);
      await pusher.trigger("private-admin-options", "integrity-check-log", {
        message: `Unknown file ${file} found in S3`,
      });
    }
  }

  await pusher.trigger("private-admin-options", "integrity-check-log", {
    message: "Checking database...",
  });

  for (const offer of offers) {
    if (offer.images.length) {
      for (const image of offer.images) {
        if (
          !files.some((file) =>
            file.includes(
              `request/${offer.requestId}/offer/${offer.id}/images/${image.name}`,
            )
          )
        ) {
          notInFiles.push(
            `request/${offer.requestId}/offer/${offer.id}/images/${image.name}`,
          );
          await pusher.trigger("private-admin-options", "integrity-check-log", {
            message:
              `File request/${offer.requestId}/offer/${offer.id}/images/${image.name} missing from S3`,
          });
        }
      }
    }
  }

  await pusher.trigger("private-admin-options", "integrity-check-log", {
    message: "Integrity check completed",
  });

  return c.json({
    message: "Integrity check completed",
  });
});

app.get(
  "/users",
  zValidator(
    "query",
    z.object({
      limit: z.string().refine(
        (value) => !isNaN(Number(value)),
        "limit must be a valid number",
      ).transform((value) => Number(value)).optional().pipe(
        z.number().min(1).max(100).default(50),
      ),
      offset: z.string().refine(
        (value) => !isNaN(Number(value)),
        "offset must be a valid number",
      ).transform((value) => Number(value)).optional().pipe(
        z.number().min(0).default(0),
      ),
      query: z.string().optional().default(""),
    }),
  ),
  async (c) => {
    const { limit, offset, query } = c.req.valid("query");

    const users = await db.query.usersTable.findMany({
      columns: {
        id: true,
        email: true,
        username: true,
        name: true,
        isAdmin: true,
        isBlocked: true,
      },
      where: or(
        ilike(usersTable.username, `%${query}%`),
        ilike(usersTable.name, `%${query}%`),
        ilike(usersTable.email, `%${query}%`),
      ),
      limit,
      offset,
      orderBy: asc(usersTable.id),
    });

    return c.json(users);
  },
);

app.post(
  "/users/:userId/switch-block",
  zValidator(
    "param",
    getUserByIdSchema,
  ),
  async (c) => {
    const { userId } = c.req.valid("param");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.id, userId),
    });

    if (!user) {
      return c.json({ message: "User not found" }, 404);
    }

    if (user.isAdmin) {
      return c.json({ message: "You cannot block an admin" }, 400);
    }

    await db.update(usersTable).set({
      isBlocked: !user.isBlocked,
    }).where(eq(usersTable.id, userId));

    await pusher.trigger("private-admin-users", "update-user-block", {
      userId,
      isBlocked: !user.isBlocked,
    });

    return c.json({
      message: "User blocked",
    });
  },
);

export default app;
