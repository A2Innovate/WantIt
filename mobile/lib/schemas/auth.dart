import 'package:acanthis/acanthis.dart';

final signUpSchema = object({
  'name': string()
      .min(2, message: 'Name must be at least 2 characters'),
  'username': string()
      .min(2, message: 'Username must be at least 2 characters')
      .pattern(
        RegExp(r'^[a-zA-Z0-9]+$'),
        message: 'Username must only contain letters and numbers',
      ),
  'email': string().email(message: 'Invalid email address'),
  'password': string()
      .min(8, message: 'Password must be at least 8 characters')
      .max(256, message: 'Password must be at most 256 characters long'),
});
final loginSchema = object({
  'email': string().email(message: 'Invalid email'),
  'password': string()
      .min(8, message: 'Password must be at least 8 characters')
      .max(256, message: 'Password must be at most 256 characters long'),
});
final requestPasswordResetSchema = object({
  'email': string().email(message: 'Invalid email'),
});
final changePasswordSchema = object({
  'oldPassword': string()
      .min(8, message: 'Password must be at least 8 characters long')
      .max(256, message: 'Password must be at most 256 characters long'),
  'newPassword': string()
      .min(8, message: 'Password must be at least 8 characters long')
      .max(256, message: 'Password must be at most 256 characters long'),
});
