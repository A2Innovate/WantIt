import { z } from 'zod';
import { CURRENCIES } from '@/utils/global';

export const updateProfileSchema = z.object({
  name: z
    .string()
    .min(2, 'Name must be at least 2 characters long')
    .max(256, 'Name must be at most 256 characters long'),
  username: z
    .string()
    .min(2, 'Username must be at least 2 characters long')
    .max(32, 'Username must be at most 32 characters long')
    .regex(/^[a-zA-Z0-9]+$/, 'Username must only contain letters and numbers'),
  email: z.string().email('Invalid email'),
  preferredCurrency: z.enum(CURRENCIES as [string, ...string[]])
});

export const getUserByIdSchema = z.object({
  userId: z
    .string()
    .refine((value) => !isNaN(Number(value)), 'userId must be a valid number')
    .transform((value) => Number(value))
});

export const createAlertSchema = z.object({
  content: z
    .string()
    .min(4, 'Content must be at least 4 characters long')
    .max(512, 'Content must be at most 512 characters long'),
  budget: z.number().max(2147483647, 'Budget must be at most 2147483647'),
  budgetComparisonMode: z.enum(COMPARISON_MODES as [string, ...string[]]),
  location: z
    .object({
      x: z.number().min(-180).max(180),
      y: z.number().min(-90).max(90)
    })
    .nullable(),
  radius: z.number().min(3000).max(1000000).nullable(),
  currency: z.enum(CURRENCIES as [string, ...string[]])
});
