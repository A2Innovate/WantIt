import { z } from 'zod';

export const addCommentSchema = z.object({
  content: z
    .string()
    .min(1, 'Content must not be empty')
    .max(512, 'Content must be at most 512 characters long'),
  offerId: z.number()
});
