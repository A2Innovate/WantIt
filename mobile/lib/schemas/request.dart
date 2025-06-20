import 'package:acanthis/acanthis.dart';

import '../utils/global.dart';

final createRequestSchema = object({
  'content': string()
      .min(4, message: "Content must be at least 4 characters long")
      .max(512, message: "Content must be at most 512 characters long"),
  'budget': number().lte(
    2147483647,
    message: "Budget must be at most 2147483647",
  ),
  'location': object({
    'x': number().gte(-180).lte(180),
    'y': number().gte(-90).lte(90),
  }).nullable(),
  'radius': number().gte(3000).lte(1000000).nullable(),
  'currency': string().enumerated(Currency.values),
  // radius: z.number().min(3000).max(1000000).nullable(),
  // currency: z.enum(CURRENCIES),
});
