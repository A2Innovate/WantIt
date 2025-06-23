import 'package:mobile/types/request.dart';

import 'comment.dart';

class OfferUserId {
  final int offerId;

  OfferUserId({required this.offerId});
}

class Offer {
  final int id;
  final int requestId;
  final UserAndId user;
  final String content;
  final int price;
  final bool negotiation;
  final List<ImageData> images;
  final List<Comment> comments;

  // final List<Comment> comments;
  final DateTime? createdAt;

  factory Offer.fromJson(Map<String, dynamic> json) {
    try {
      return Offer(
        json['id'] as int,
        json['requestId'] as int,
        UserAndId(json['user']['username'], json['user']['id']),
        json['content'] as String,
        (json['price'] as num).toInt(),
        json['negotiation'] as bool,
        (json['images'] as List).map((img) => ImageData.fromJson(img)).toList(),
        json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        (json['comments'] as List)
            .map((comment) => Comment.fromJson(comment))
            .toList(),
      );
    } catch (e) {
      throw FormatException('Failed to parse Offer: $e');
    }
  }

  Offer(
    this.id,
    this.requestId,
    this.user,
    this.content,
    this.price,
    this.negotiation,
    this.images,
    this.createdAt,
    this.comments,
  );
}

class ImageData {
  final String name;
  ImageData({required this.name});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    try {
      return ImageData(name: json['name'] as String);
    } catch (e) {
      throw FormatException('Failed to parse ImageData: $e');
    }
  }
}
