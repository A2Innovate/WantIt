import 'dart:async';

import 'package:mobile/api/client.dart';
import 'package:mobile/utils/global.dart';

List<Rate> _cachedRates = [];

class Rate {
  final Currency currency;
  final double rate;

  Rate({required this.currency, required this.rate});

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(
      currency: Currency.values.firstWhere(
        (c) => c.symbol == json['currency'],
        orElse: () =>
            throw Exception('Unknown currency symbol: ${json['currency']}'),
      ),
      rate: (json['rate'] as num).toDouble(),
    );
  }
}

Future<List<Rate>> getRates() async {
  if (_cachedRates.isNotEmpty) {
    return _cachedRates;
  }

  final response = await useApi().get('/currency');

  _cachedRates.addAll(
    (response.data as List).map(
      (e) => Rate.fromJson(e as Map<String, dynamic>),
    ),
  );

  return _cachedRates;
}

Future<double> convertCurrency(Currency from, Currency to, int amount) async {
  final rates = await getRates();
  double amountInEUR;
  if (from == Currency.EUR) {
    amountInEUR = amount.toDouble();
  } else {
    final fromRate = rates.firstWhere(
      (r) => r.currency == from,
      orElse: () => throw Exception('Currency rate not found for $from'),
    );
    amountInEUR = amount / fromRate.rate;
  }
  if (to == Currency.EUR) {
    return amountInEUR;
  } else {
    final toRate = rates.firstWhere(
      (r) => r.currency == to,
      orElse: () => throw Exception('Currency rate not found for $to'),
    );
    return amountInEUR * toRate.rate;
  }
}
