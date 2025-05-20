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

export const userRelations = relations(usersTable, ({ many }) => ({
  requests: many(requestsTable),
}));

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

export const requestsRelations = relations(requestsTable, ({ one, many }) => ({
  user: one(usersTable, {
    fields: [requestsTable.userId],
    references: [usersTable.id],
  }),
  offers: many(offersTable),
}));

export const offersTable = pgTable("offers", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  requestId: integer()
    .notNull()
    .references(() => requestsTable.id, { onDelete: "cascade" }),
  userId: integer()
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  content: text().notNull(),
  price: integer().notNull(),
  negotiation: boolean().notNull().default(false),
});

export const offersRelations = relations(offersTable, ({ one }) => ({
  request: one(requestsTable, {
    fields: [offersTable.requestId],
    references: [requestsTable.id],
  }),
  user: one(usersTable, {
    fields: [offersTable.userId],
    references: [usersTable.id],
  }),
}));
