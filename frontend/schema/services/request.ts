import { z } from 'zod';
import { CURRENCIES } from '@/utils/global';

export const createRequestSchema = z
  .object({
    content: z
      .string()
      .min(4, 'Content must be at least 4 characters long')
      .max(512, 'Content must be at most 512 characters long'),
    budget: z.number().max(2147483647, 'Budget must be at most 2147483647'),
    location: z
      .object({
        x: z.number().min(-180).max(180),
        y: z.number().min(-90).max(90)
      })
      .nullable(),
    radius: z.number().min(3000).max(1000000).nullable(),
    currency: z.enum(CURRENCIES as [string, ...string[]])
  })
  .refine(
    (data) =>
      (data.location !== null && data.radius !== null) ||
      (data.location === null && data.radius === null),
    {
      message:
        'Either both location and radius must be provided, or both must be null'
    }
  );

export const editRequestSchema = z
  .object({
    content: z
      .string()
      .min(4, 'Content must be at least 4 characters long')
      .max(512, 'Content must be at most 512 characters long'),
    budget: z.number().max(2147483647, 'Budget must be at most 2147483647'),
    location: z
      .object({
        x: z.number().min(-180).max(180),
        y: z.number().min(-90).max(90)
      })
      .nullable(),
    radius: z.number().min(3000).max(1000000).nullable()
  })
  .refine(
    (data) =>
      (data.location !== null && data.radius !== null) ||
      (data.location === null && data.radius === null),
    {
      message:
        'Either both location and radius must be provided, or both must be null'
    }
  );

export const createAndEditOfferSchema = z.object({
  content: z
    .string()
    .min(4, 'Content must be at least 4 characters long')
    .max(512, 'Content must be at most 512 characters long'),
  price: z.number().max(2147483647, 'Price must be at most 2147483647'),
  negotiation: z.boolean().default(false)
});

export const requestByIdSchema = z.object({
  requestId: z
    .string()
    .refine(
      (value) => !isNaN(Number(value)),
      'requestId must be a valid number'
    )
    .transform((value) => Number(value))
});
