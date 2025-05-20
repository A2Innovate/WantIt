import { z } from 'zod';

export const updateProfileSchema = z.object({
  name: z
    .string()
    .min(2, 'Name must be at least 2 characters long')
    .max(256, 'Name must be at most 256 characters long'),
  email: z.string().email('Invalid email')
});

export const getUserByIdSchema = z.object({
  userId: z
    .string()
    .refine((value) => !isNaN(Number(value)), 'userId must be a valid number')
    .transform((value) => Number(value))
});
