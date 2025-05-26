import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { and, asc, desc, eq, notInArray, or } from "drizzle-orm";
import { messagesTable, usersTable } from "@/db/schema.ts";
import { zValidator } from "@hono/zod-validator";
import {
  paramPersonIdSchema,
  sendChatMessageSchema,
} from "@/schema/services/chat.ts";

const app = new Hono();

app.get("/", authRequired, async (c) => {
  const session = c.get("session");

  // Last messages from other users
  const lastMessagesFromOtherUsers = await db
    .selectDistinctOn([messagesTable.senderId], {
      createdAt: messagesTable.createdAt,
      content: messagesTable.content,
      person: {
        id: usersTable.id,
        name: usersTable.name,
      },
    })
    .from(messagesTable)
    .innerJoin(usersTable, eq(messagesTable.senderId, usersTable.id))
    .where(eq(messagesTable.receiverId, session.user.id))
    .orderBy(messagesTable.senderId, desc(messagesTable.createdAt));

  // Last messages sent by user
  const lastMessagesFromUser = await db
    .selectDistinctOn([messagesTable.receiverId], {
      createdAt: messagesTable.createdAt,
      content: messagesTable.content,
      person: {
        id: usersTable.id,
        name: usersTable.name,
      },
    })
    .from(messagesTable)
    .innerJoin(usersTable, eq(messagesTable.receiverId, usersTable.id))
    .where(
      and(
        eq(messagesTable.senderId, session.user.id),
        notInArray(
          messagesTable.receiverId,
          lastMessagesFromOtherUsers.map((msg) => msg.person.id),
        ),
      ),
    )
    .orderBy(messagesTable.receiverId, desc(messagesTable.createdAt));

  return c.json([...lastMessagesFromOtherUsers, ...lastMessagesFromUser]);
});

app.get(
  "/:personId",
  zValidator(
    "param",
    paramPersonIdSchema,
  ),
  authRequired,
  async (c) => {
    const session = c.get("session");
    const { personId } = c.req.valid("param");

    const person = await db.query.usersTable.findFirst({
      where: eq(usersTable.id, personId),
    });

    if (!person) {
      return c.json({ message: "Person not found" }, 404);
    }

    const messages = await db.query.messagesTable.findMany({
      where: or(
        and(
          eq(messagesTable.senderId, personId),
          eq(messagesTable.receiverId, session.user.id),
        ),
        and(
          eq(messagesTable.receiverId, personId),
          eq(messagesTable.senderId, session.user.id),
        ),
      ),
      columns: {
        id: true,
        content: true,
        createdAt: true,
        senderId: true,
      },
      orderBy: asc(messagesTable.createdAt),
    });

    return c.json({
      person: {
        name: person.name,
        id: person.id,
      },
      messages,
    });
  },
);

app.post(
  "/:personId",
  zValidator(
    "param",
    paramPersonIdSchema,
  ),
  zValidator(
    "json",
    sendChatMessageSchema,
  ),
  authRequired,
  async (c) => {
    const session = c.get("session");
    const { personId } = c.req.valid("param");
    const { content } = c.req.valid("json");

    const person = await db.query.usersTable.findFirst({
      where: eq(usersTable.id, personId),
    });

    if (!person) {
      return c.json({ message: "Person not found" }, 404);
    }

    const message = await db.insert(messagesTable).values({
      senderId: session.user.id,
      receiverId: personId,
      content,
    }).returning();

    return c.json(message[0], 200);
  },
);

export default app;
