import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { and, desc, eq, or } from "drizzle-orm";
import { messagesTable, usersTable } from "@/db/schema.ts";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";

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

app.get(
  "/:chatUserId",
  zValidator(
    "param",
    z.object({
      chatUserId: z.string().refine(
        (value) => !isNaN(Number(value)),
        "chatUserId must be a valid number",
      ).transform((value) => Number(value)),
    }),
  ),
  authRequired,
  async (c) => {
    const session = c.get("session");
    const { chatUserId } = c.req.valid("param");

    const sender = await db.query.usersTable.findFirst({
      where: eq(usersTable.id, chatUserId),
    });

    if (!sender) {
      return c.json({ message: "Sender not found" }, 404);
    }

    const messages = await db.query.messagesTable.findMany({
      where: or(
        and(
          eq(messagesTable.senderId, chatUserId),
          eq(messagesTable.receiverId, session.user.id),
        ),
        and(
          eq(messagesTable.receiverId, chatUserId),
          eq(messagesTable.senderId, session.user.id),
        ),
      ),
      with: {
        sender: {
          columns: {
            id: true,
          },
        },
      },
      columns: {
        id: true,
        content: true,
        createdAt: true,
      },
      orderBy: desc(messagesTable.createdAt),
    });

    return c.json({
      sender: {
        name: sender.name,
        id: sender.id,
      },
      messages,
    });
  },
);

export default app;
