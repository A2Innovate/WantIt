import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { eq } from "drizzle-orm";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { userSessionsTable, usersTable } from "@/db/schema.ts";
import { generateEmailVerificationToken } from "@/utils/generate.ts";
import { sendMail } from "@/utils/mail.ts";

const app = new Hono();
app.put(
  "/update",
  zValidator(
    "json",
    z.object({
      name: z.string().min(2, "Name must be at least 2 characters long").max(
        256,
        "Name must be at most 256 characters long",
      ),
      email: z.string().email("Invalid email"),
    }),
  ),
  authRequired,
  async (c) => {
    const session = c.get("session");
    const { name, email } = c.req.valid("json");

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
        return c.json({ error: "User with this email already exists" }, 409);
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

        To activate your account, click the link below:
        ${
          Deno.env.get("FRONTEND_URL")
        }/auth/verify-email/${emailVerificationToken}
        
        Best regards,
        WantIt Team
        `,
      });
    }

    return c.json({ message: "Updated successfully" }, 200);
  },
);

export default app;
