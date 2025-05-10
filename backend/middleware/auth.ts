import { db } from "@/db/index.ts";
import { userSessionsTable, usersTable } from "@/db/schema.ts";
import { deleteCookie, getCookie } from "hono/cookie";
import { eq } from "drizzle-orm";
import { InferSelectModel } from "drizzle-orm";
import { createMiddleware } from "hono/factory";

export const authRequired = createMiddleware<{
  Variables: {
    session: InferSelectModel<typeof userSessionsTable> & {
      user: InferSelectModel<typeof usersTable>;
    };
  };
}>(async (c, next) => {
  const sessionToken = getCookie(c, "session");

  if (!sessionToken) {
    return c.json({
      message: "Session token missing.",
    }, 401);
  }

  const session = await db.query.userSessionsTable.findFirst({
    where: eq(userSessionsTable.sessionToken, sessionToken),
    with: {
      user: true,
    },
  });

  if (!session || session.expiresAt < new Date()) {
    deleteCookie(c, "session");
    return c.json({
      message: "Incorrect session token.",
    }, 401);
  }

  c.set("session", session);

  await next();
});
