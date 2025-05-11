import type { ZodSchema } from 'zod';

export function validate<T>(schema: ZodSchema<T>, data: T) {
  const validation = schema.safeParse(data);
  if (!validation.success) {
    return validation.error.issues[0].message;
  }
}
