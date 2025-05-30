import { z } from "zod";
import { CURRENCIES } from "@/utils/global.ts";

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
