import 'package:acanthis/acanthis.dart';

import '../utils/global.dart';

final createAndEditRequestSchema =
    object({
      'content': string()
          .min(4, message: "validation_request_content_min_length")
          .max(512, message: "validation_request_content_max_length"),
      'budget': number()
          .lte(2147483647, message: "validation_request_budget_max_length")
          .gte(0, message: "validation_request_budget_min_length"),
      'location': object({
        'x': number().gte(-180).lte(180),
        'y': number().gte(-90).lte(90),
      }).nullable(),
      'radius': number().gte(3000).lte(1000000).nullable(),
      'currency': string().enumerated(Currency.values),
    }).refine(
      onCheck: (value) {
        if ((value['location'] != null && value['radius'] != null) ||
            (value['location'] == null && value['radius'] == null)) {
          return true;
        }
        return false;
      },
      error: "validation_request_location_radius",
      name: 'message',
    );

final createAndEditOfferSchema = object({
  'content': string()
      .min(4, message: "validation_offer_content_min_length")
      .max(512, message: "validation_offer_content_max_length"),
  'price': number()
      .lte(2147483647, message: "validation_offer_price_max_length")
      .gte(0, message: "validation_offer_price_min_length"),
  'negotiation': boolean().nullable(defaultValue: false),
});
