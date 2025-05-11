import { z } from "zod";

export const createRequestSchema = z.object({
  content: z.string().min(4, "Content must be at least 4 characters long").max(
    512,
    "Content must be at most 512 characters long",
  ),
  budget: z.number(),
});

export const requestByIdSchema = z.object({
  requestId: z.string().refine(
    (value) => !isNaN(Number(value)),
    "requestId must be a valid number",
  ).transform((value) => Number(value)),
});
