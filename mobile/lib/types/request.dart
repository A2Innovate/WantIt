import 'package:latlong2/latlong.dart';
import 'package:mobile/types/offer.dart';

import '../utils/global.dart';

class UserAndId {
  final String username;
  final int id;
  UserAndId(this.username, this.id);
  factory UserAndId.fromJson(Map<String, dynamic> json) {
    final username = json['username'];
    final id = json['id'];
    if (username == null || id == null) {
      throw FormatException('Missing required fields: username or id');
    }
    if (username is! String || id is! int) {
      throw FormatException(
        'Invalid field types: username must be String, id must be int',
      );
    }
    return UserAndId(username, id);
  }
}

class Request {
  final int id;
  String content;
  final UserAndId user;
  int budget;
  Currency currency;
  LatLng? location;
  double? radius;
  final List<Offer>? offers;
  final OfferUserId? acceptedOffer;
  final DateTime? createdAt;

  factory Request.fromJson(Map<String, dynamic> json) {
    try {
      LatLng? location;
      if (json['location'] != null) {
        location = LatLng(
          (json['location']['y'] as num).toDouble(),
          (json['location']['x'] as num).toDouble(),
        );
      }
      return Request(
        id: json['id'],
        content: json['content'],
        user: UserAndId.fromJson(json['user'] as Map<String, dynamic>),
        budget: (json['budget'] as num).toInt(),
        currency: Currency.values.byName(json['currency']),
        location: location,
        offers: (json['offers'] as List?)
            ?.map((offer) => Offer.fromJson(offer))
            .toList(),
        acceptedOffer: json['acceptedOffer'] == null
            ? null
            : OfferUserId(offerId: json['acceptedOffer']['offerId'] as int),
        radius: (json['radius'] as num?)?.toDouble(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
    } on FormatException {
      throw Exception('Failed to parse request data');
    }
  }

  void applyPartialUpdate(Map<String, dynamic> json) {
    if (json.containsKey('content')) {
      content = json['content'] as String;
    }

    if (json.containsKey('budget')) {
      budget = (json['budget'] as num).toInt();
    }

    if (json.containsKey('currency')) {
      currency = Currency.values.byName(json['currency']);
    }

    if (json.containsKey('location')) {
      final loc = json['location'];
      if (loc == null) {
        location = null;
      } else {
        location = LatLng(
          (loc['y'] as num).toDouble(),
          (loc['x'] as num).toDouble(),
        );
      }
    }

    if (json.containsKey('radius')) {
      final r = json['radius'];
      radius = r == null ? null : (r as num).toDouble();
    }
  }

  Request({
    required this.id,
    required this.content,
    required this.user,
    required this.budget,
    required this.currency,
    required this.location,
    required this.radius,
    required this.offers,
    required this.acceptedOffer,
    required this.createdAt,
  });
}
