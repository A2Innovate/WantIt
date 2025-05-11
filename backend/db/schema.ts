import {
  boolean,
  integer,
  pgTable,
  text,
  timestamp,
} from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";

export const usersTable = pgTable("users", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  name: text().notNull(),
  email: text().notNull(),
  isEmailVerified: boolean().notNull().default(false),
  emailVerificationToken: text().unique(),
  password: text().notNull(),
  passwordResetToken: text().unique(),
});

export const userSessionsTable = pgTable("user_sessions", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  userId: integer()
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  sessionToken: text().notNull().unique(),
  expiresAt: timestamp().notNull(),
});

export const userSessionsRelations = relations(
  userSessionsTable,
  ({ one }) => ({
    user: one(usersTable, {
      fields: [userSessionsTable.userId],
      references: [usersTable.id],
    }),
  }),
);

export const requestsTable = pgTable("requests", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  userId: integer()
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  content: text().notNull(),
  budget: integer().notNull(),
});

export const requestsRelations = relations(requestsTable, ({ one }) => ({
  user: one(usersTable, {
    fields: [requestsTable.userId],
    references: [usersTable.id],
  }),
}));
