import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { desc, eq } from "drizzle-orm";
import { messagesTable, usersTable } from "@/db/schema.ts";

const app = new Hono();

app.get("/", authRequired, async (c) => {
  const session = c.get("session");

  // Last message from each sender
  const lastMessages = await db
    .selectDistinctOn([messagesTable.senderId], {
      createdAt: messagesTable.createdAt,
      content: messagesTable.content,
      sender: {
        id: usersTable.id,
        name: usersTable.name,
      },
    })
    .from(messagesTable)
    .innerJoin(usersTable, eq(messagesTable.senderId, usersTable.id))
    .where(eq(messagesTable.receiverId, session.user.id))
    .orderBy(messagesTable.senderId, desc(messagesTable.createdAt));

  return c.json(lastMessages);
});

export default app;
