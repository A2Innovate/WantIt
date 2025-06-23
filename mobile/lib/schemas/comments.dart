import 'package:acanthis/acanthis.dart';

final addCommentSchema = object({
  'content': string()
      .min(1, message: "Content must not be empty")
      .max(512, message: "Content must be at most 512 characters long"),
  'offerId': number(),
});
final editCommentSchema = object({
  'content': string()
      .min(1, message: "Content must not be empty")
      .max(512, message: "Content must be at most 512 characters long"),
});
