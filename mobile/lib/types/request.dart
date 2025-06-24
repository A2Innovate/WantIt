import 'package:latlong2/latlong.dart';
import 'package:mobile/types/offer.dart';

import '../utils/global.dart';

class UserAndId {
  final String username;
  final int id;
  UserAndId(this.username, this.id);
  factory UserAndId.fromJson(Map<String, dynamic> json) {
    return UserAndId(json['username'], json['id']);
  }
}

// id: number;
// content: string;
// user: Omit<User, 'email' | 'preferredCurrency' | 'sessionId' | 'isAdmin'>;
// budget: number;
// currency: string;
// location: {
// x: number;
// y: number;
// } | null;
// radius: number | null;
// offers: Offer[];
// acceptedOffer: { offerId: number } | null;
// createdAt: string;
class Request {
  final int id;
  final String content;
  final UserAndId user;
  final int budget;
  final Currency currency;
  final LatLng? location;
  final double? radius;
  late List<Offer>? offers;
  final OfferUserId? acceptedOffer;
  final String? createdAt;

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
        user: UserAndId(json['user']['username'], json['user']['id']),
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
        createdAt: json['createdAt'],
      );
    } on FormatException {
      throw Exception('Failed to parse request data');
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
