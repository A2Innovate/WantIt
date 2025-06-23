import 'package:mobile/types/request.dart';

final class Comment {
  final int id;
  final String content;
  final bool edited;
  final DateTime createdAt;
  final UserAndId user;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      edited: json['edited'],
      createdAt: DateTime.parse(json['createdAt']),
      user: UserAndId.fromJson(json['user']),
    );
  }

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.edited,
    required this.user,
  });
}
