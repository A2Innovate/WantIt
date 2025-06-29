import { z } from "zod";
import { COMPARISON_MODES, CURRENCIES } from "@/utils/global.ts";

export const updateProfileSchema = z.object({
  name: z.string().min(2, "validation_name_min_length").max(
    256,
    "validation_name_max_length",
  ),
  username: z.string().min(2, "validation_username_min_length")
    .max(
      32,
      "validation_username_max_length",
    ).regex(/^[a-zA-Z0-9]+$/, "validation_username_regex"),
  email: z.string().email("validation_email"),
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
    .min(4, "validation_alert_content_min_length")
    .max(512, "validation_alert_content_max_length"),
  budget: z
    .number()
    .max(2147483647, "validation_alert_budget_max_length"),
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
    message: "validation_alert_location_radius",
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
    .min(4, "validation_review_content_min_length")
    .max(512, "validation_review_content_max_length")
    .nullable(),
  rating: z.number().min(1, "validation_review_rating_min_length").max(
    5,
    "validation_review_rating_max_length",
  ),
});
