import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { eq } from "drizzle-orm";
import { zValidator } from "@hono/zod-validator";
import { userSessionsTable, usersTable } from "@/db/schema.ts";
import { generateEmailVerificationToken } from "@/utils/generate.ts";
import { sendMail } from "@/utils/mail.ts";
import {
  getUserByIdSchema,
  updateProfileSchema,
} from "@/schema/services/user.ts";
import { FRONTEND_URL } from "@/utils/global.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";

const app = new Hono();

app.get(
  "/:userId",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  zValidator("param", getUserByIdSchema),
  async (c) => {
    const { userId } = c.req.valid("param");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.id, userId),
      with: {
        requests: {
          columns: {
            userId: false,
          },
        },
      },
      columns: {
        name: true,
        username: true,
      },
    });

    if (!user) {
      return c.json({ message: "User not found" }, 404);
    }

    return c.json(user);
  },
);

app.put(
  "/update",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator(
    "json",
    updateProfileSchema,
  ),
  authRequired,
  async (c) => {
    const session = c.get("session");
    const { name, email, preferredCurrency, username } = c.req.valid("json");

    if (session.user.name !== name) {
      await db.update(usersTable).set({
        name,
      }).where(eq(usersTable.id, session.user.id));
    }

    if (session.user.email !== email) {
      const existingUser = await db.select().from(usersTable).where(
        eq(usersTable.email, email),
      );

      if (existingUser.length > 0) {
        return c.json({ message: "User with this email already exists" }, 409);
      }

      await db.delete(userSessionsTable).where(
        eq(userSessionsTable.sessionToken, session.sessionToken),
      );

      const emailVerificationToken = await generateEmailVerificationToken();

      await db.update(usersTable).set({
        email: email,
        isEmailVerified: false,
        emailVerificationToken: emailVerificationToken,
      }).where(eq(usersTable.id, session.user.id));

      await sendMail({
        to: email,
        subject: "WantIt - Email verification",

        text: `Hi ${session.user.name}!

        To confirm your email update, click the link below:
        ${FRONTEND_URL}/auth/verify-email/${emailVerificationToken}
        
        Best regards,
        WantIt Team
        `,
      });
    }

    if (session.user.preferredCurrency !== preferredCurrency) {
      await db.update(usersTable).set({
        preferredCurrency,
      }).where(eq(usersTable.id, session.user.id));
    }

    if (session.user.username !== username) {
      try {
        await db.update(usersTable).set({
          username,
        }).where(eq(usersTable.id, session.user.id));
      } catch (error) {
        if (
          error instanceof Error &&
          error.message ===
            'duplicate key value violates unique constraint "users_username_unique"'
        ) {
          return c.json({ message: "Username already exists" }, 409);
        }
      }
    }

    return c.json({ message: "Updated successfully" }, 200);
  },
);

export default app;
