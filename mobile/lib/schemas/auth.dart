import 'package:acanthis/acanthis.dart';

final signUpSchema = object({
  'name': string()
      .min(2, message: 'validation_name_min_length')
      .max(256, message: 'validation_name_max_length'),
  'username': string()
      .min(2, message: 'validation_username_min_length')
      .max(32, message: 'validation_username_max_length')
      .pattern(RegExp(r'^[a-zA-Z0-9]+$'), message: 'validation_username_regex'),
  'email': string().email(message: 'validation_email'),
  'password': string()
      .min(8, message: 'validation_password_min_length')
      .max(256, message: 'validation_password_max_length'),
});

final loginSchema = object({
  'email': string().email(message: 'validation_email'),
  'password': string()
      .min(8, message: 'validation_password_min_length')
      .max(256, message: 'validation_password_max_length'),
});

final requestPasswordResetSchema = object({
  'email': string().email(message: 'validation_email'),
});

final resetPasswordSchema = object({
  'password': string()
      .min(8, message: 'validation_password_min_length')
      .max(256, message: 'validation_password_max_length'),
  'token': string(),
});

final changePasswordSchema = object({
  'oldPassword': string()
      .min(8, message: 'validation_password_min_length')
      .max(256, message: 'validation_password_max_length'),
  'newPassword': string()
      .min(8, message: 'validation_password_min_length')
      .max(256, message: 'validation_password_max_length'),
});
