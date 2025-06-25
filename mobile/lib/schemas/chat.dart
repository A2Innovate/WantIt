import 'package:acanthis/acanthis.dart';

final sendChatMessageSchema = object({
  'content': string()
      .min(1, message: 'Content must not be empty')
      .max(4096, message: 'Content must be at most 4096 characters long'),
});
