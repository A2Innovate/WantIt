import { z } from 'zod';
import { CURRENCIES } from '@/utils/global';

export const createRequestSchema = z
  .object({
    content: z
      .string()
      .min(4, 'validation_request_content_min_length')
      .max(512, 'validation_request_content_max_length'),
    budget: z
      .number()
      .min(0, 'validation_request_budget_min_length')
      .max(2147483647, 'validation_request_budget_max_length'),
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
      message: 'validation_request_location_radius'
    }
  );

export const editRequestSchema = z
  .object({
    content: z
      .string()
      .min(4, 'validation_request_content_min_length')
      .max(512, 'validation_request_content_max_length'),
    budget: z.number()
    .min(0, 'validation_request_budget_min_length')
    .max(2147483647, 'validation_request_budget_max_length'),
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
      message: 'validation_request_location_radius'
    }
  );

export const createAndEditOfferSchema = z.object({
  content: z
    .string()
    .min(4, 'validation_offer_content_min_length')
    .max(512, 'validation_offer_content_max_length'),
  price: z
    .number()
    .min(0, 'validation_offer_price_min_length')
    .max(2147483647, 'validation_offer_price_max_length'),
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
