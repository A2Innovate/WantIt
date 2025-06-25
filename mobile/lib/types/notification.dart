// export enum NotificationType {
//   NEW_OFFER = 'NEW_OFFER',
//   NEW_MESSAGE = 'NEW_MESSAGE',
//   NEW_OFFER_COMMENT = 'NEW_OFFER_COMMENT',
//   NEW_ALERT_MATCH = 'NEW_ALERT_MATCH',
//   OFFER_ACCEPTED = 'OFFER_ACCEPTED'
// }
//
// export interface Notification {
// id: number;
// userId: number;
// relatedUserId: number | null;
// relatedOfferId: number | null;
// relatedRequestId: number | null;
// relatedUser?: Pick<User, 'name'>;
// relatedOffer?: Offer;
// relatedRequest?: Request;
// type: NotificationType;
// read: boolean;
// createdAt: string;
// }

enum NotificationType {
  NEW_OFFER,
  NEW_MESSAGE,
  NEW_OFFER_COMMENT,
  NEW_ALERT_MATCH,
  OFFER_ACCEPTED,
}

class RelatedUser {
  final int? id;
  final String? name;

  RelatedUser({required this.id, required this.name});

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
  final int userId;
  final int? relatedUserId;
  final int? relatedOfferId;
  final int? relatedRequestId;
  final RelatedUser? relatedUser;
  final RelatedOffer? relatedOffer;
  // Change the field’s type
  final int? relatedRequest;
  final NotificationType type;
  final bool read;
  final DateTime createdAt;

  NotificationData({
    required this.id,
    required this.userId,
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
