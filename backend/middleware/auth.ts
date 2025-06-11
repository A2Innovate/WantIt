import { db } from "@/db/index.ts";
import { userSessionsTable, usersTable } from "@/db/schema.ts";
import { deleteCookie, getCookie } from "hono/cookie";
import { eq } from "drizzle-orm";
import { InferSelectModel } from "drizzle-orm";
import { createMiddleware } from "hono/factory";
import { z } from "zod";

export const authRequired = createMiddleware<{
  Variables: {
    session: InferSelectModel<typeof userSessionsTable> & {
      user: InferSelectModel<typeof usersTable>;
    };
  };
}>(async (c, next) => {
  const sessionToken = getCookie(c, "wantit_session");

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
    deleteCookie(c, "wantit_session");
    return c.json({
      message: "Incorrect session token.",
    }, 401);
  }

  if (session.user.isBlocked) {
    return c.json({
      message: "You are blocked.",
    }, 401);
  }

  if (session.user.isAdmin && c.req.query("pretendUser")) {
    let pretendUserId;

    try {
      pretendUserId = z.number().min(1).parse(
        Number(c.req.query("pretendUser")),
      );
    } catch {
      return c.json({
        message: "Invalid pretend user ID.",
      }, 400);
    }

    const pretendUser = await db.query.usersTable.findFirst({
      where: eq(usersTable.id, pretendUserId),
    });

    if (!pretendUser) {
      return c.json({
        message: "Pretend user not found.",
      }, 404);
    }

    if (pretendUser.id === session.user.id) {
      return c.json({
        message: "You cannot pretend to be yourself.",
      }, 400);
    }

    if (pretendUser.isAdmin) {
      return c.json({
        message: "You cannot pretend to be another admin.",
      }, 400);
    }

    session.user = pretendUser;
  }

  c.set("session", session);

  await next();
});

export const adminRequired = createMiddleware(async (c, next) => {
  const session = c.get("session");

  if (!session.user.isAdmin) {
    return c.json({
      message: "You do not have permission to perform this action.",
    }, 403);
  }

  await next();
});
