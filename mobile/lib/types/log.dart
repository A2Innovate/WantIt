// import type { User } from './user';
//
// export interface Log {
// id: number;
// type: string;
// user?: Pick<User, 'id' | 'name' | 'username'>;
// ip?: string;
// content?: string;
// createdAt: string;
// }

import 'package:mobile/types/request.dart';

class Log {
  final int id;
  final String type;
  final String? content;
  final String? ip;
  final DateTime createdAt;
  final UserAndId? user;

  Log({
    required this.id,
    required this.type,
    required this.content,
    required this.ip,
    required this.createdAt,
    required this.user,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      ip: json['ip'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.fromMillisecondsSinceEpoch(0),
      ),
      user: json['user'] != null ? UserAndId.fromJson(json['user']) : null,
    );
  }
}
