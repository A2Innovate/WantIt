import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { db } from "@/db/index.ts";
import { eq } from "drizzle-orm";
import { userSessionsTable, usersTable } from "@/db/schema.ts";
import {
  generateEmailVerificationToken,
  generateSessionToken,
} from "@/utils/generate.ts";
import argon2 from "argon2";
import { sendMail } from "@/utils/mail.ts";
import { setCookie } from "hono/cookie";
import { authRequired } from "@/middleware/auth.ts";

const app = new Hono();

app.get("/", authRequired, (c) => {
  const session = c.get("session");

  return c.json({
    id: session.user.id,
    email: session.user.email,
    name: session.user.name,
  });
});

app.post(
  "/register",
  zValidator(
    "json",
    z.object({
      name: z.string().min(2, "Name must be at least 2 characters long").max(
        256,
        "Name must be at most 256 characters long",
      ),
      email: z.string().email("Invalid email"),
      password: z.string().min(
        8,
        "Password must be at least 8 characters long",
      ).max(
        256,
        "Password must be at most 256 characters long",
      ),
    }),
  ),
  async (c) => {
    const { name, email, password } = c.req.valid("json");

    const existingUser = await db.query.usersTable.findFirst({
      where: eq(usersTable.email, email),
    });

    if (existingUser) {
      return c.json({ error: "User with this email already exists" }, 409);
    }

    const hashedPassword = await argon2.hash(password);
    const emailVerificationToken = await generateEmailVerificationToken();

    await sendMail({
      to: email,
      subject: "WantIt - Email verification",

      text: `Hi ${name}!

      Thank you for registering to WantIt!
      To activate your account, click the link below:
      ${
        Deno.env.get("FRONTEND_URL")
      }/auth/verify-email/${emailVerificationToken}
      
      If you did not register to WantIt, please ignore this email.
      
      Best regards,
      WantIt Team
      `,
    });

    await db.insert(usersTable).values({
      name,
      email,
      password: hashedPassword,
      emailVerificationToken,
    });

    return c.json({ message: "Registered successfully" }, 201);
  },
);

app.post(
  "/login",
  zValidator(
    "json",
    z.object({
      email: z.string().email("Invalid email"),
      password: z.string().min(
        8,
        "Password must be at least 8 characters long",
      ).max(
        256,
        "Password must be at most 256 characters long",
      ),
    }),
  ),
  async (c) => {
    const { email, password } = c.req.valid("json");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.email, email),
    });

    if (!user) {
      // Intentional, user should not know which one is wrong
      return c.json({ error: "Incorrect email or password" }, 401);
    }

    if (!(await argon2.verify(user.password, password))) {
      return c.json({ error: "Incorrect email or password" }, 401);
    }

    if (!user.isEmailVerified) {
      return c.json({ error: "Email is not verified" }, 401);
    }

    const sessionToken = await generateSessionToken();

    await db.insert(userSessionsTable).values({
      userId: user.id,
      sessionToken,
      expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30), // 30 days
    });

    setCookie(c, "session", sessionToken, {
      httpOnly: true,
      secure: true,
      sameSite: "lax",
      maxAge: 60 * 60 * 24 * 30, // 30 days
    });

    return c.json({
      id: user.id,
      email: user.email,
      name: user.name,
    }, 200);
  },
);

app.post("/verify-email/:token", async (c) => {
  const token = c.req.param("token");

  const user = await db.query.usersTable.findFirst({
    where: eq(usersTable.emailVerificationToken, token),
  });

  if (!user) {
    return c.json({ error: "Invalid token" }, 400);
  }

  await db.update(usersTable).set({
    isEmailVerified: true,
    emailVerificationToken: null,
  }).where(eq(usersTable.id, user.id));

  return c.json({ message: "Email verified successfully" }, 200);
});

app.post("/logout", authRequired, async (c) => {
  const session = c.get("session");

  await db.delete(userSessionsTable).where(
    eq(userSessionsTable.sessionToken, session.sessionToken),
  );

  return c.json({ message: "Logged out successfully" }, 200);
});

export default app;
