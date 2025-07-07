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
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      preferredCurrency: Currency.values.firstWhere(
        (currency) => currency.name == json['preferredCurrency'],
        orElse: () => Currency.USD,
      ),
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

class ProfileData {
  final String name;
  final String username;
  final List<RequestData> requests;

  ProfileData({
    required this.name,
    required this.username,
    required this.requests,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'],
      username: json['username'],
      requests: List<RequestData>.from(
        json['requests'].map((request) => RequestData.fromJson(request)),
      ),
    );
  }
}

class RequestData {
  final int id;
  final String content;
  final int budget;
  final Currency currency;
  final DateTime createdAt;

  RequestData({
    required this.id,
    required this.content,
    required this.budget,
    required this.currency,
    required this.createdAt,
  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      id: json['id'],
      content: json['content'],
      budget: (json['budget'] as num).toInt(),
      currency: Currency.values.byName(json['currency']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
