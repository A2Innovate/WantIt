import { z } from "zod";
import { CURRENCIES } from "@/utils/global.ts";

export const createRequestSchema = z.object({
  content: z
    .string()
    .min(4, "Content must be at least 4 characters long")
    .max(512, "Content must be at most 512 characters long"),
  budget: z
    .number()
    .max(2147483647, "Budget must be at most 2147483647"),
  location: z
    .object({
      x: z.number().min(-180).max(180),
      y: z.number().min(-90).max(90),
    })
    .nullable(),
  radius: z.number().min(3000).max(1000000).nullable(),
  currency: z.enum(CURRENCIES),
});

export const editRequestSchema = z.object({
  content: z
    .string()
    .min(4, "Content must be at least 4 characters long")
    .max(512, "Content must be at most 512 characters long"),
  budget: z.number().max(2147483647, "Budget must be at most 2147483647"),
  location: z.object({
    x: z.number().min(-180).max(180),
    y: z.number().min(-90).max(90),
  }).nullable(),
  radius: z.number().min(3000).max(1000000).nullable(),
});

export const createAndEditOfferSchema = z.object({
  content: z
    .string()
    .min(4, "Content must be at least 4 characters long")
    .max(512, "Content must be at most 512 characters long"),
  price: z
    .number()
    .max(2147483647, "Price must be at most 2147483647"),
  negotiation: z.boolean().default(false),
});

export const requestByIdSchema = z.object({
  requestId: z
    .string()
    .refine(
      (value) => !isNaN(Number(value)),
      "requestId must be a valid number",
    )
    .transform((value) => Number(value)),
});

export const offerByIdSchema = z.object({
  offerId: z
    .string()
    .refine(
      (value) => !isNaN(Number(value)),
      "offerId must be a valid number",
    )
    .transform((value) => Number(value)),
});
