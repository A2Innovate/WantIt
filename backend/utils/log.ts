import { logsTable } from "@/db/schema.ts";
import { db } from "@/db/index.ts";
import { pusher } from "@/utils/pusher.ts";

export async function createLog({
  message,
  userId,
}: {
  message: string;
  userId?: number;
}) {
  const [log] = await db.insert(logsTable).values({
    message,
    userId,
  }).returning();

  pusher.trigger(
    `private-admin-logs`,
    "new-log",
    log,
  ).catch((e) => {
    console.error(`Async Pusher trigger error: ${e}`);
  });
}
