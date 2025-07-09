import 'package:acanthis/acanthis.dart';

final sendChatMessageSchema = object({
  'content': string()
      .min(1, message: 'validation_chat_content_min_length')
      .max(4096, message: 'validation_chat_content_max_length'),
});
