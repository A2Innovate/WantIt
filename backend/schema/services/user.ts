import { z } from "zod";
import { COMPARISON_MODES, CURRENCIES } from "@/utils/global.ts";

export const updateProfileSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters long").max(
    256,
    "Name must be at most 256 characters long",
  ),
  username: z.string().min(2, "Username must be at least 2 characters long")
    .max(
      32,
      "Username must be at most 32 characters long",
    ).regex(/^[a-zA-Z0-9]+$/, "Username must only contain letters and numbers"),
  email: z.string().email("Invalid email"),
  preferredCurrency: z.enum(CURRENCIES),
});

export const getUserByIdSchema = z.object({
  userId: z.string().refine(
    (value) => !isNaN(Number(value)),
    "userId must be a valid number",
  ).transform((value) => Number(value)),
});

export const createEditAlertSchema = z.object({
  content: z
    .string()
    .min(4, "Content must be at least 4 characters long")
    .max(512, "Content must be at most 512 characters long"),
  budget: z
    .number()
    .max(2147483647, "Budget must be at most 2147483647"),
  budgetComparisonMode: z.enum(COMPARISON_MODES),
  location: z
    .object({
      x: z.number().min(-180).max(180),
      y: z.number().min(-90).max(90),
    })
    .nullable(),
  radius: z.number().min(3000).max(1000000).nullable(),
  currency: z.enum(CURRENCIES),
}).refine(
  (data) =>
    (data.location !== null && data.radius !== null) ||
    (data.location === null && data.radius === null),
  {
    message:
      "Either both location and radius must be provided, or both must be null",
  },
);

export const alertByIdSchema = z.object({
  alertId: z.string().refine(
    (value) => !isNaN(Number(value)),
    "alertId must be a valid number",
  ).transform((value) => Number(value)),
});

export const reviewByIdSchema = z.object({
  reviewId: z.string().refine(
    (value) => !isNaN(Number(value)),
    "reviewId must be a valid number",
  ).transform((value) => Number(value)),
});

export const addEditReviewSchema = z.object({
  content: z
    .string()
    .min(4, "Content must be at least 4 characters long")
    .max(512, "Content must be at most 512 characters long")
    .nullable(),
  rating: z.number().min(1, "Rating must be at least 1").max(
    5,
    "Rating must be at most 5",
  ),
});
