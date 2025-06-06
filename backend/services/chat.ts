import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { and, asc, desc, eq, notInArray, or } from "drizzle-orm";
import { messagesTable, notificationsTable, usersTable } from "@/db/schema.ts";
import { zValidator } from "@hono/zod-validator";
import {
  paramPersonIdSchema,
  sendChatMessageSchema,
} from "@/schema/services/chat.ts";
import { pusher } from "@/utils/pusher.ts";
import z from "zod";

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
        username: usersTable.username,
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
        username: usersTable.username,
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
        edited: true,
      },
      orderBy: asc(messagesTable.createdAt),
    });

    return c.json({
      person: {
        id: person.id,
        username: person.username,
        name: person.name,
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

    if (personId === session.user.id) {
      return c.json({ message: "You cannot send a message to yourself" }, 400);
    }

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

    pusher.trigger(
      `private-user-${personId}-chat-${session.user.id}`,
      "new-message",
      message[0],
    ).catch((e) => {
      console.error(`Async Pusher trigger error: ${e}`);
    });

    const notification = await db.insert(notificationsTable).values({
      userId: personId,
      relatedUserId: session.user.id,
      type: "NEW_MESSAGE",
    }).returning();

    pusher.trigger(
      `private-user-${personId}`,
      "new-notification",
      {
        ...notification[0],
        relatedUser: {
          id: session.user.id,
          name: session.user.name,
        },
      },
    ).catch((e) => {
      console.error(`Async Pusher trigger error: ${e}`);
    });

    return c.json(message[0], 200);
  },
);

app.put(
  "/message/:messageId",
  authRequired,
  zValidator(
    "param",
    z.object({
      messageId: z.string().refine(
        (value) => !isNaN(Number(value)),
        "messageId must be a valid number",
      ).transform((value) => Number(value)),
    }),
  ),
  zValidator(
    "json",
    sendChatMessageSchema,
  ),
  async (c) => {
    const session = c.get("session");
    const { messageId } = c.req.valid("param");
    const { content } = c.req.valid("json");

    const message = await db.query.messagesTable.findFirst({
      where: eq(messagesTable.id, messageId),
    });

    if (!message) {
      return c.json({ message: "Message not found" }, 404);
    }

    if (message.senderId !== session.user.id) {
      return c.json({ message: "You cannot edit this message" }, 400);
    }

    await db.update(messagesTable).set({
      content,
      edited: true,
    }).where(eq(messagesTable.id, messageId));

    pusher.trigger(
      `private-user-${message.receiverId}-chat-${session.user.id}`,
      "update-message",
      {
        id: messageId,
        content,
      },
    ).catch((e) => {
      console.error(`Async Pusher trigger error: ${e}`);
    });

    pusher.trigger(
      `private-user-${session.user.id}-chat-${message.receiverId}`,
      "update-message",
      {
        id: messageId,
        content,
      },
    ).catch((e) => {
      console.error(`Async Pusher trigger error: ${e}`);
    });

    return c.json({ message: "Message edited" }, 200);
  },
);
export default app;
