import { z } from "zod";

export const notificationByIdSchema = z.object({
  notificationId: z
    .string()
    .refine(
      (value) => !isNaN(Number(value)),
      "notificationId must be a valid number",
    )
    .transform((value) => Number(value)),
});
