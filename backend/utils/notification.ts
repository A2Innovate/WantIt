import { db } from "@/db/index.ts";
import {
  notificationsTable,
  offersTable,
  requestsTable,
  usersTable,
} from "@/db/schema.ts";
import { InferInsertModel, InferSelectModel } from "drizzle-orm";
import { pusher } from "@/utils/pusher.ts";

interface Notification {
  type: InferInsertModel<typeof notificationsTable>["type"];
  relatedOfferId?: number;
  relatedRequestId?: number;
  relatedUserId?: number;
  relatedOffer?: Partial<InferSelectModel<typeof offersTable>>;
  relatedRequest?: Partial<InferSelectModel<typeof requestsTable>>;
  relatedUser?: Partial<InferSelectModel<typeof usersTable>>;
  userId: number;
}

export async function createNotification({
  type,
  relatedOfferId,
  relatedRequestId,
  relatedUserId,
  relatedUser,
  relatedRequest,
  relatedOffer,
  userId,
}: Notification) {
  const [notification] = await db.insert(notificationsTable).values({
    type,
    relatedOfferId,
    relatedRequestId,
    relatedUserId,
    userId,
  }).returning();

  const payload:
    & Omit<Notification, "userId">
    & Pick<InferSelectModel<typeof notificationsTable>, "id" | "createdAt"> = {
      type,
      relatedOfferId,
      relatedRequestId,
      relatedUserId,
      id: notification.id,
      createdAt: notification.createdAt,
    };

  if (relatedUser) {
    payload.relatedUser = relatedUser;
  }

  if (relatedRequest) {
    payload.relatedRequest = relatedRequest;
  }

  if (relatedOffer) {
    payload.relatedOffer = relatedOffer;
  }

  await pusher.trigger(
    `private-user-${userId}`,
    "new-notification",
    payload,
  );
}
