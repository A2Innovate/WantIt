import { Hono } from "hono";
import { adminRequired } from "@/middleware/auth.ts";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { sql } from "drizzle-orm";
import { requestsTable, usersTable } from "@/db/schema.ts";
import { offersTable } from "@/db/schema.ts";

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

export default app;
