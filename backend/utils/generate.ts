import crypto from "node:crypto";
import { db } from "@/db/index.ts";
import { eq } from "drizzle-orm";
import { usersTable } from "@/db/schema.ts";

export async function generateEmailVerificationToken() {
  const token = crypto.randomBytes(32).toString("hex");

  const existingToken = await db.query.usersTable.findFirst({
    where: eq(usersTable.emailVerificationToken, token),
  });

  if (existingToken) {
    return generateEmailVerificationToken();
  }

  return token;
}
