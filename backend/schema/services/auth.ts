import { z } from "zod";

export const signUpSchema = z.object({
  name: z.string().min(2, "validation_name_min_length").max(
    256,
    "validation_name_max_length",
  ),
  username: z.string().min(2, "validation_username_min_length")
    .max(
      32,
      "validation_username_max_length",
    ).regex(/^[a-zA-Z0-9]+$/, "validation_username_regex"),
  email: z.string().email("validation_email"),
  password: z.string().min(
    8,
    "validation_password_min_length",
  ).max(
    256,
    "validation_password_max_length",
  ),
});

export const loginSchema = z.object({
  email: z.string().email("validation_email"),
  password: z.string().min(
    8,
    "validation_password_min_length",
  ).max(
    256,
    "validation_password_max_length",
  ),
});

export const requestPasswordResetSchema = z.object({
  email: z.string().email("validation_email"),
});

export const resetPasswordSchema = z.object({
  password: z.string().min(
    8,
    "validation_password_min_length",
  ).max(
    256,
    "validation_password_max_length",
  ),
  token: z.string(),
});

export const changePasswordSchema = z.object({
  oldPassword: z
    .string()
    .min(8, "validation_password_min_length")
    .max(256, "validation_password_max_length"),
  newPassword: z
    .string()
    .min(8, "validation_password_min_length")
    .max(256, "validation_password_max_length"),
});
