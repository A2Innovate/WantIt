import { z } from "zod";
import { CURRENCIES } from "@/utils/global.ts";

export const updateProfileSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters long").max(
    256,
    "Name must be at most 256 characters long",
  ),
  email: z.string().email("Invalid email"),
  preferredCurrency: z.enum(CURRENCIES),
});

export const getUserByIdSchema = z.object({
  userId: z.string().refine(
    (value) => !isNaN(Number(value)),
    "userId must be a valid number",
  ).transform((value) => Number(value)),
});
