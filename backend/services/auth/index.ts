import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import { db } from "@/db/index.ts";
import { and, desc, eq } from "drizzle-orm";
import { userSessionsTable, usersTable } from "@/db/schema.ts";
import {
  generateEmailVerificationToken,
  generateResetPasswordToken,
  generateSessionToken,
} from "@/utils/generate.ts";
import argon2 from "argon2";
import { sendMail } from "@/utils/mail.ts";
import { deleteCookie, setCookie } from "hono/cookie";
import { authRequired } from "@/middleware/auth.ts";
import {
  changePasswordSchema,
  loginSchema,
  requestPasswordResetSchema,
  resetPasswordSchema,
  signUpSchema,
} from "@/schema/services/auth.ts";
import oauth from "./oauth.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";
import { COOKIE_DOMAIN, COOKIE_SECURE, FRONTEND_URL } from "@/utils/global.ts";
import { pusher } from "@/utils/pusher.ts";
import { z } from "zod";
import { getIp } from "@/utils/ip.ts";

const app = new Hono();

app.route("/oauth", oauth);

app.get(
  "/",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  (c) => {
    const session = c.get("session");

    return c.json({
      id: session.user.id,
      email: session.user.email,
      name: session.user.name,
      username: session.user.username,
      preferredCurrency: session.user.preferredCurrency,
      sessionId: session.id,
      isAdmin: session.user.isAdmin,
    });
  },
);

app.get(
  "/sessions",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  async (c) => {
    const session = c.get("session");

    const sessions = await db.query.userSessionsTable.findMany({
      where: eq(userSessionsTable.userId, session.user.id),
      columns: {
        id: true,
        ip: true,
        expiresAt: true,
      },
      orderBy: desc(userSessionsTable.expiresAt),
    });

    return c.json(sessions);
  },
);

app.delete(
  "/session/:sessionId",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  zValidator(
    "param",
    z.object({
      sessionId: z.string().refine(
        (value) => !isNaN(Number(value)),
        "sessionId must be a valid number",
      ).transform((value) => Number(value)),
    }),
  ),
  async (c) => {
    const session = c.get("session");
    const { sessionId } = c.req.valid("param");

    await db.delete(userSessionsTable).where(
      and(
        eq(userSessionsTable.id, sessionId),
        eq(userSessionsTable.userId, session.user.id),
      ),
    );

    return c.json({ message: "Session revoked successfully" }, 200);
  },
);

app.post(
  "/pusher",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  zValidator(
    "json",
    z.object({
      socket_id: z.string(),
      channel_name: z.string(),
    }),
  ),
  (c) => {
    const session = c.get("session");
    const { socket_id, channel_name } = c.req.valid("json");
    const channel_parts = channel_name.split("-");

    const isValidChatChannel = channel_parts.length === 5 &&
      channel_parts[0] === "private" &&
      channel_parts[1] === "user" &&
      channel_parts[2] === session.user.id.toString() &&
      channel_parts[3] === "chat";

    const isValidUserChannel = channel_parts.length === 3 &&
      channel_parts[0] === "private" &&
      channel_parts[1] === "user" &&
      channel_parts[2] === session.user.id.toString();

    const isValidUserAlertsChannel = channel_parts.length === 4 &&
      channel_parts[0] === "private" &&
      channel_parts[1] === "user" &&
      channel_parts[2] === session.user.id.toString() &&
      channel_parts[3] === "alerts";

    const isValidUserAlertChannel = channel_parts.length === 5 &&
      channel_parts[0] === "private" &&
      channel_parts[1] === "user" &&
      channel_parts[2] === session.user.id.toString() &&
      channel_parts[3] === "alert" &&
      !isNaN(Number(channel_parts[4]));

    const isValidAdminStatsChannel = channel_parts.length === 3 &&
      channel_parts[0] === "private" &&
      channel_parts[1] === "admin" &&
      channel_parts[2] === "stats" &&
      session.user.isAdmin;

    const isValidAdminLogsChannel = channel_parts.length === 3 &&
      channel_parts[0] === "private" &&
      channel_parts[1] === "admin" &&
      channel_parts[2] === "logs" &&
      session.user.isAdmin;

    if (
      isValidChatChannel || isValidUserChannel || isValidUserAlertsChannel ||
      isValidUserAlertChannel || isValidAdminStatsChannel ||
      isValidAdminLogsChannel
    ) {
      const auth = pusher.authorizeChannel(socket_id, channel_name);
      return c.json(auth);
    }

    return c.json({ message: "Unauthorized" }, 401);
  },
);

app.post(
  "/register",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 10,
  }),
  zValidator(
    "json",
    signUpSchema,
  ),
  async (c) => {
    const { name, username, email, password } = c.req.valid("json");

    const existingUser = await db.query.usersTable.findFirst({
      where: eq(usersTable.email, email),
    });

    if (existingUser) {
      return c.json({ message: "User with this email already exists" }, 409);
    }

    const hashedPassword = await argon2.hash(password);
    const emailVerificationToken = await generateEmailVerificationToken();

    try {
      await sendMail({
        to: email,
        subject: "WantIt - Email verification",
        text: `Hi ${name}!

        Thank you for registering to WantIt!
        To activate your account, click the link below:
        ${FRONTEND_URL}/auth/verify-email/${emailVerificationToken}
        
        If you did not register to WantIt, please ignore this email.
        
        Best regards,
        WantIt Team`,
      });
    } catch (error) {
      console.error("Failed to send email:", error);
      return c.json({
        message:
          "Sending verification email failed, please try again later or use OAuth to register.",
      }, 500);
    }

    await db.insert(usersTable).values({
      name,
      username,
      email,
      password: hashedPassword,
      emailVerificationToken,
    });

    pusher.trigger("private-admin-stats", "update-users", 1).catch(
      (error) => {
        console.error("Async Pusher trigger error: ", error);
      },
    );

    return c.json({ message: "Registered successfully" }, 201);
  },
);

app.post(
  "/login",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 100,
  }),
  zValidator(
    "json",
    loginSchema,
  ),
  async (c) => {
    const { email, password } = c.req.valid("json");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.email, email),
    });

    if (!user) {
      // Intentional, user should not know which one is wrong
      return c.json({ message: "Incorrect email or password" }, 401);
    }

    if (!user.password) {
      return c.json({
        message:
          "This account has no password, it was likely created with OAuth, please use OAuth to login or reset your password.",
      }, 400);
    }

    if (!(await argon2.verify(user.password, password))) {
      return c.json({ message: "Incorrect email or password" }, 401);
    }

    if (!user.isEmailVerified) {
      return c.json({ message: "Email is not verified" }, 401);
    }

    const sessionToken = await generateSessionToken();

    const [session] = await db.insert(userSessionsTable).values({
      userId: user.id,
      sessionToken,
      ip: getIp(c),
      expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30), // 30 days
    }).returning({
      id: userSessionsTable.id,
    });

    setCookie(c, "wantit_session", sessionToken, {
      httpOnly: true,
      secure: COOKIE_SECURE,
      sameSite: "lax",
      domain: COOKIE_DOMAIN,
      maxAge: 60 * 60 * 24 * 30, // 30 days
    });

    return c.json({
      id: user.id,
      email: user.email,
      name: user.name,
      username: user.username,
      preferredCurrency: user.preferredCurrency,
      isAdmin: user.isAdmin,
      sessionId: session.id,
    }, 200);
  },
);

app.post(
  "/verify-email/:token",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 10,
  }),
  async (c) => {
    const token = c.req.param("token");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.emailVerificationToken, token),
    });

    if (!user) {
      return c.json({ message: "Invalid token" }, 400);
    }

    await db.update(usersTable).set({
      isEmailVerified: true,
      emailVerificationToken: null,
    }).where(eq(usersTable.id, user.id));

    return c.json({ message: "Email verified successfully" }, 200);
  },
);

app.post("/logout", authRequired, async (c) => {
  const session = c.get("session");

  await db.delete(userSessionsTable).where(
    eq(userSessionsTable.sessionToken, session.sessionToken),
  );

  deleteCookie(c, "wantit_session");

  return c.json({ message: "Logged out successfully" }, 200);
});

app.post(
  "/request-password-reset",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 5,
  }),
  zValidator("json", requestPasswordResetSchema),
  async (c) => {
    const { email } = c.req.valid("json");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.email, email),
    });

    if (!user) {
      return c.json({ message: "User not found" }, 404);
    }

    const resetPasswordToken = await generateResetPasswordToken();

    await sendMail({
      to: email,
      subject: "WantIt - Reset password",

      text: `Hi ${user.name}!

      To reset your password, click the link below:
      ${FRONTEND_URL}/auth/reset-password/${resetPasswordToken}
      
      Best regards,
      WantIt Team
      `,
    });

    await db.update(usersTable).set({
      passwordResetToken: resetPasswordToken,
    }).where(eq(usersTable.id, user.id));

    return c.json({ message: "Reset password email sent successfully" }, 200);
  },
);

app.post(
  "/reset-password",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 5,
  }),
  zValidator("json", resetPasswordSchema),
  async (c) => {
    const { password, token } = c.req.valid("json");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.passwordResetToken, token),
    });

    if (!user) {
      return c.json({ message: "Invalid token" }, 400);
    }

    await db.update(usersTable).set({
      password: await argon2.hash(password),
      passwordResetToken: null,
    }).where(eq(usersTable.id, user.id));

    // Remove this user's sessions
    await db.delete(userSessionsTable).where(
      eq(userSessionsTable.userId, user.id),
    );

    return c.json({ message: "Password reset successfully" }, 200);
  },
);
app.post(
  "/change-password",
  authRequired,
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 10,
  }),
  zValidator("json", changePasswordSchema),
  async (c) => {
    const { oldPassword, newPassword } = c.req.valid("json");

    const session = c.get("session");

    if (!session.user.password) {
      return c.json({
        message:
          "This account has no password, it was likely created using OAuth, please reset your password.",
      }, 400);
    }

    if (!(await argon2.verify(session.user.password, oldPassword))) {
      return c.json({ message: "Incorrect old password" }, 401);
    }

    await db.update(usersTable).set({
      password: await argon2.hash(newPassword),
    }).where(eq(usersTable.id, session.user.id));

    return c.json({ message: "Password changed successfully" }, 200);
  },
);

export default app;
