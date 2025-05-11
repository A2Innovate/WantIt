import crypto from "node:crypto";
import { db } from "@/db/index.ts";
import { eq } from "drizzle-orm";
import { userSessionsTable, usersTable } from "@/db/schema.ts";

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

export async function generateResetPasswordToken() {
  const token = crypto.randomBytes(32).toString("hex");

  const existingToken = await db.query.usersTable.findFirst({
    where: eq(usersTable.passwordResetToken, token),
  });

  if (existingToken) {
    return generateResetPasswordToken();
  }

  return token;
}

export async function generateSessionToken() {
  const token = crypto.randomBytes(32).toString("hex");

  const existingToken = await db.query.userSessionsTable.findFirst({
    where: eq(userSessionsTable.sessionToken, token),
  });

  if (existingToken) {
    return generateSessionToken();
  }

  return token;
}
