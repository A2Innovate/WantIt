import {
  boolean,
  geometry,
  integer,
  pgEnum,
  pgTable,
  text,
  timestamp,
} from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";
import { CURRENCIES, NOTIFICATION_TYPES } from "../utils/global.ts";

export const currencies = pgEnum("currencies", CURRENCIES);
export const notificationTypes = pgEnum(
  "notification_types",
  NOTIFICATION_TYPES,
);

export const usersTable = pgTable("users", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  username: text().notNull().unique(),
  name: text().notNull(),
  email: text().notNull(),
  isEmailVerified: boolean().notNull().default(false),
  emailVerificationToken: text().unique(),
  password: text(),
  passwordResetToken: text().unique(),
  isAdmin: boolean().notNull().default(false),
  preferredCurrency: currencies().notNull().default("USD"),
  createdAt: timestamp().notNull().defaultNow(),
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
  ip: text(),
  expiresAt: timestamp().notNull(),
  createdAt: timestamp().notNull().defaultNow(),
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
  edited: boolean().notNull().default(false),
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
  location: geometry("location", { type: "point", mode: "xy", srid: 4326 }),
  radius: integer(),
  createdAt: timestamp().notNull().defaultNow(),
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
  createdAt: timestamp().notNull().defaultNow(),
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

export const notificationsTable = pgTable("notifications", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  userId: integer()
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  relatedUserId: integer()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  relatedOfferId: integer()
    .references(() => offersTable.id, { onDelete: "cascade" }),
  relatedRequestId: integer()
    .references(() => requestsTable.id, { onDelete: "cascade" }),
  type: notificationTypes().notNull(),
  read: boolean().notNull().default(false),
  createdAt: timestamp().notNull().defaultNow(),
});

export const notificationsRelations = relations(
  notificationsTable,
  ({ one }) => ({
    relatedUser: one(usersTable, {
      fields: [notificationsTable.relatedUserId],
      references: [usersTable.id],
    }),
    relatedOffer: one(offersTable, {
      fields: [notificationsTable.relatedOfferId],
      references: [offersTable.id],
    }),
    relatedRequest: one(requestsTable, {
      fields: [notificationsTable.relatedRequestId],
      references: [requestsTable.id],
    }),
  }),
);

export const alertsTable = pgTable("alerts", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  userId: integer()
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),
  content: text().notNull(),
  budget: integer().notNull(),
  currency: currencies().notNull().default("USD"),
  location: geometry("location", { type: "point", mode: "xy", srid: 4326 }),
  radius: integer(),
  createdAt: timestamp().notNull().defaultNow(),
});
