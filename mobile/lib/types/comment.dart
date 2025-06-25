import 'package:mobile/types/request.dart';

final class Comment {
  final int id;
  final int? offerId;
  String content;
  bool? edited;
  final DateTime createdAt;
  final UserAndId user;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      offerId: json['offerId'],
      content: json['content'],
      edited: json['edited'],
      createdAt: DateTime.parse(json['createdAt']),
      user: UserAndId.fromJson(json['user']),
    );
  }
  void applyPartialUpdate(Map<String, dynamic> json) {
    if (json.containsKey('content')) {
      content = json['content'] as String;
    }
    edited = true;
  }

  Comment({
    required this.id,
    this.offerId,
    required this.content,
    required this.createdAt,
    required this.edited,
    required this.user,
  });
}
