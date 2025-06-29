import 'package:acanthis/acanthis.dart';

final addCommentSchema = object({
  'content': string()
      .min(1, message: "validation_comment_content_min_length")
      .max(512, message: "validation_comment_content_max_length"),
  'offerId': number(),
});
final editCommentSchema = object({
  'content': string()
      .min(1, message: "validation_comment_content_min_length")
      .max(512, message: "validation_comment_content_max_length"),
});
