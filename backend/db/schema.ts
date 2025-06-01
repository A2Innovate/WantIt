import {
  boolean,
  geometry,
  integer,
  pgEnum,
  pgTable,
  text,
  timestamp,
} from "drizzle-orm/pg-core";
import { relations, sql } from "drizzle-orm";
import { CURRENCIES } from "../utils/global.ts";

export const currencies = pgEnum("currencies", CURRENCIES);

export const usersTable = pgTable("users", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  username: text().notNull().unique(),
  name: text().notNull(),
  email: text().notNull(),
  isEmailVerified: boolean().notNull().default(false),
  emailVerificationToken: text().unique(),
  password: text(),
  passwordResetToken: text().unique(),
  preferredCurrency: currencies().notNull().default("USD"),
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

export const messagesTable = pgTable("messages", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  senderId: integer()
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  receiverId: integer()
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  content: text().notNull(),
  createdAt: timestamp().notNull().defaultNow(),
});

export const messagesRelations = relations(messagesTable, ({ one }) => ({
  sender: one(usersTable, {
    fields: [messagesTable.senderId],
    references: [usersTable.id],
  }),
  receiver: one(usersTable, {
    fields: [messagesTable.receiverId],
    references: [usersTable.id],
  }),
}));

export const requestsTable = pgTable("requests", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  userId: integer()
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  content: text().notNull(),
  budget: integer().notNull(),
  currency: currencies().notNull().default("USD"),
  location: geometry("location", { type: "point", mode: "xy", srid: 4326 })
    .notNull().default(sql`ST_SetSRID(ST_MakePoint(-122.419, 37.78), 4326)`),
  radius: integer().notNull().default(1000000),
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

export const offerImagesTable = pgTable("offer_images", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  offerId: integer()
    .notNull()
    .references(() => offersTable.id, { onDelete: "cascade" }),
  name: text().notNull(),
});

export const offerImagesRelations = relations(
  offerImagesTable,
  ({ one }) => ({
    offer: one(offersTable, {
      fields: [offerImagesTable.offerId],
      references: [offersTable.id],
    }),
  }),
);

export const offersRelations = relations(offersTable, ({ one, many }) => ({
  request: one(requestsTable, {
    fields: [offersTable.requestId],
    references: [requestsTable.id],
  }),
  user: one(usersTable, {
    fields: [offersTable.userId],
    references: [usersTable.id],
  }),
  images: many(offerImagesTable),
  comments: many(commentsTable),
}));

export const commentsTable = pgTable("comments", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  requestId: integer()
    .references(() => requestsTable.id, { onDelete: "cascade" }),
  offerId: integer()
    .references(() => offersTable.id, { onDelete: "cascade" }),
  userId: integer()
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  content: text().notNull(),
  edited: boolean().notNull().default(false),
  createdAt: timestamp().notNull().defaultNow(),
});

export const commentsRelations = relations(commentsTable, ({ one }) => ({
  user: one(usersTable, {
    fields: [commentsTable.userId],
    references: [usersTable.id],
  }),
  offer: one(offersTable, {
    fields: [commentsTable.offerId],
    references: [offersTable.id],
  }),
}));
