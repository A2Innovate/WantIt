import '../utils/global.dart';

class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final Currency preferredCurrency;
  final int sessionId;
  final bool? isAdmin;
  final bool? isBlocked;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.preferredCurrency,
    required this.sessionId,
    required this.isAdmin,
    required this.isBlocked,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print(json);
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      preferredCurrency: Currency.values.byName(json['preferredCurrency']),
      sessionId: json['sessionId'],
      isAdmin: json['isAdmin'],
      isBlocked: json['isBlocked'],
    );
  }
}

class UserSession {
  final int id;
  final String ip;
  final DateTime expiresAt;

  UserSession({required this.id, required this.ip, required this.expiresAt});

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'],
      ip: json['ip'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
