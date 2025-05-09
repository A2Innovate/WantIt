import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { db } from "@/db/index.ts";
import { eq } from "drizzle-orm";
import { usersTable } from "@/db/schema.ts";
import { generateEmailVerificationToken } from "@/utils/generate.ts";
import argon2 from "argon2";
import { sendMail } from "@/utils/mail.ts";

const app = new Hono();

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
      return c.json({ error: "User with this email already exists" }, 400);
    }

    const hashedPassword = await argon2.hash(password);
    const emailVerificationToken = await generateEmailVerificationToken();

    await sendMail({
      to: email,
      subject: "WantIt - Email verification",

      // TODO: Update link when frontend for email verification is ready
      text: `Hi ${name}!

      Thank you for registering to WantIt!
      To activate your account, click the link below:
      ${Deno.env.get("BASE_URL")}/auth/verify-email/${emailVerificationToken}
      
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

export default app;
