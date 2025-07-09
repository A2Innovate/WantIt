// ignore_for_file: constant_identifier_names

enum NotificationType {
  NEW_OFFER,
  NEW_MESSAGE,
  NEW_OFFER_COMMENT,
  NEW_ALERT_MATCH,
  OFFER_ACCEPTED,
}

class RelatedUser {
  final int? id;
  final String name;

  RelatedUser({this.id, required this.name});

  factory RelatedUser.fromJson(Map<String, dynamic> json) {
    return RelatedUser(id: json['id'], name: json['name']);
  }

  @override
  String toString() => 'RelatedUser(id: $id, name: $name)';
}

class RelatedOffer {
  final String? content;

  RelatedOffer({required this.content});

  factory RelatedOffer.fromJson(Map<String, dynamic> json) {
    return RelatedOffer(content: json['content']);
  }

  @override
  String toString() => 'RelatedOffer(content: $content)';
}

class NotificationData {
  final int id;
  final int? userId;
  final int? relatedUserId;
  final int? relatedOfferId;
  final int? relatedRequestId;
  final RelatedUser? relatedUser;
  final RelatedOffer? relatedOffer;
  final int? relatedRequest;
  final NotificationType type;
  bool read;
  final DateTime createdAt;

  NotificationData({
    required this.id,
    this.userId,
    this.relatedUserId,
    this.relatedOfferId,
    this.relatedRequestId,
    this.relatedUser,
    this.relatedOffer,
    this.relatedRequest,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationData(
        id: json['id'],
        userId: json['userId'],
        relatedUserId: json['relatedUserId'],
        relatedOfferId: json['relatedOfferId'],
        relatedRequestId: json['relatedRequestId'],
        relatedUser: json['relatedUser'] != null
            ? RelatedUser.fromJson(json['relatedUser'])
            : null,
        relatedOffer: json['relatedOffer'] != null
            ? RelatedOffer.fromJson(json['relatedOffer'])
            : null,

        relatedRequest: null,
        type: NotificationType.values.byName(json['type']),
        read: json['read'],
        createdAt: DateTime.parse(json['createdAt']),
      );
    } catch (e) {
      rethrow;
    }
  }
}
