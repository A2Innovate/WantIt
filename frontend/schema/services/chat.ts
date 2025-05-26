import { z } from 'zod';

export const paramPersonIdSchema = z.object({
  personId: z
    .string()
    .refine((value) => !isNaN(Number(value)), 'personId must be a valid number')
    .transform((value) => Number(value))
});

export const sendChatMessageSchema = z.object({
  content: z
    .string()
    .min(1, 'Content must not be empty')
    .max(4096, 'Content must be at most 4096 characters long')
});
