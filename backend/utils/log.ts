import { logsTable, usersTable } from "@/db/schema.ts";
import { db } from "@/db/index.ts";
import { pusher } from "@/utils/pusher.ts";
import { eq, InferInsertModel, InferSelectModel } from "drizzle-orm";

export async function createLog({
  type,
  userId,
  ip,
}: {
  type: InferInsertModel<typeof logsTable>["type"];
  userId?: number;
  ip?: string;
}) {
  const [log] = await db.insert(logsTable).values({
    type,
    userId,
    ip,
  }).returning({
    id: logsTable.id,
    type: logsTable.type,
    createdAt: logsTable.createdAt,
    ip: logsTable.ip,
  });

  const payload: typeof log & {
    user?: Pick<
      InferSelectModel<typeof usersTable>,
      "id" | "username" | "name"
    >;
  } = log;

  if (userId) {
    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.id, userId),
      columns: {
        id: true,
        username: true,
        name: true,
      },
    });

    payload.user = user;
  }

  pusher.trigger(
    `private-admin-logs`,
    "new-log",
    payload,
  ).catch((e) => {
    console.error(`Async Pusher trigger error: ${e}`);
  });
}
