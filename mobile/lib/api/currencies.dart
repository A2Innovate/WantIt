import 'dart:async';

import 'package:mobile/api/client.dart';
import 'package:mobile/utils/global.dart';

final List<Rate> rates = [];

class Rate {
  final Currency currency;
  final double rate;

  Rate({required this.currency, required this.rate});

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(
      currency: Currency.values.firstWhere((c) => c.symbol == json['currency']),
      rate: (json['rate'] as num).toDouble(),
    );
  }
}

Future<List<Rate>> getRates() async {
  if (rates.isNotEmpty) {
    return rates;
  }

  final response = await useApi().get('/currency');

  rates.addAll((response.data as List)
      .map((e) => Rate.fromJson(e as Map<String, dynamic>)));
  for (var i = 0; i < rates.length; i++) {
    print(rates[i].currency);
  }

  return rates;
}

Future<double> convert_currency(Currency from, Currency to, amount) async {
  final rates = await getRates();
  var amountInEUR;
  if (from == Currency.EUR) {
    amountInEUR = amount;
  } else {
    final fromRate = rates.firstWhere((r) => r.currency == from);
    amountInEUR = amount / fromRate.rate;
  }
  if (to == Currency.EUR) {
    return amountInEUR;
  } else {
    print(to);
    final toRate = rates.firstWhere((r) => r.currency == to);
    return amountInEUR * toRate.rate;
  }
}
