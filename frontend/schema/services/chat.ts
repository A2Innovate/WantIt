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
    .min(1, 'validation_chat_content_min_length')
    .max(4096, 'validation_chat_content_max_length')
});
