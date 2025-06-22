import 'package:mobile/types/request.dart';

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

  // final List<Comment> comments;
  final DateTime? createdAt;

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      json['id'],
      json['requestId'],
      UserAndId(json['user']['username'], json['user']['id']),
      json['content'],
      (json['price'] as num).toInt(),
      json['negotiation'],
      (json['images'] as List).map((img) => ImageData.fromJson(img)).toList(),
      DateTime.parse(json['createdAt']),
    );
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
  );
}

class ImageData {
  final String name;

  ImageData({required this.name});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(name: json['name']);
  }
}
