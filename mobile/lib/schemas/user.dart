import 'package:acanthis/acanthis.dart';
import 'package:mobile/utils/global.dart';

final updateProfileSchema = object({
  'name': string()
      .min(2, message: 'validation_name_min_length')
      .max(256, message: 'validation_name_max_length'),
  'username': string()
      .min(2, message: 'validation_username_min_length')
      .max(32, message: 'validation_username_max_length')
      .pattern(RegExp(r'^[a-zA-Z0-9]+$'), message: 'validation_username_regex'),
  'email': string().email(message: 'validation_email'),
  'preferredCurrency': string().enumerated(Currency.values),
});
