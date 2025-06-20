import 'package:acanthis/acanthis.dart';
import 'package:mobile/utils/global.dart';

final updateProfileSchema = object({
  'name': string()
      .min(2, message: 'Name must be at least 2 characters')
      .max(256, message: 'Name must be at most 256 characters long'),
  'username': string()
      .min(2, message: 'Username must be at least 2 characters')
      .pattern(
        RegExp(r'^[a-zA-Z0-9]+$'),
        message: 'Username must only contain letters and numbers',
      ),
  'email': string().email(message: 'Invalid email'),
  'preferredCurrency': string().enumerated(Currency.values),
});
