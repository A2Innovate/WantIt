import 'dart:math';

import 'package:intl/intl.dart';

enum Currency {
  USD,
  PLN,
  EUR,
  GBP,
  JPY,
  BGN,
  CZK,
  DKK,
  HUF,
  RON,
  SEK,
  CHF,
  ISK,
  NOK,
  TRY,
  AUD,
  BRL,
  CAD,
  CNY,
  HKD,
  IDR,
  ILS,
  INR,
  KRW,
  MXN,
  MYR,
  NZD,
  PHP,
  SGD,
  THB,
  ZAR,
}

extension CurrencyExtension on Currency {
  String get name {
    switch (this) {
      case Currency.USD:
        return 'United States dollar';
      case Currency.PLN:
        return 'Polish złoty';
      case Currency.EUR:
        return 'Euro';
      case Currency.GBP:
        return 'British Pound Sterling';
      case Currency.JPY:
        return 'Japanese Yen';
      case Currency.BGN:
        return 'Bulgarian Lev';
      case Currency.CZK:
        return 'Czech koruna';
      case Currency.DKK:
        return 'Danish Krone';
      case Currency.HUF:
        return 'Hungarian Forint';
      case Currency.RON:
        return 'Romanian Leu';
      case Currency.SEK:
        return 'Swedish Krona';
      case Currency.CHF:
        return 'Swiss Franc';
      case Currency.ISK:
        return 'Icelandic Krona';
      case Currency.NOK:
        return 'Norwegian Krone';
      case Currency.TRY:
        return 'Turkish Lira';
      case Currency.AUD:
        return 'Australian Dollar';
      case Currency.BRL:
        return 'Brazilian Real';
      case Currency.CAD:
        return 'Canadian Dollar';
      case Currency.CNY:
        return 'Chinese Yuan';
      case Currency.HKD:
        return 'Hong Kong Dollar';
      case Currency.IDR:
        return 'Indonesian Rupiah';
      case Currency.ILS:
        return 'Israeli Shekel';
      case Currency.INR:
        return 'Indian Rupee';
      case Currency.KRW:
        return 'South Korean Won';
      case Currency.MXN:
        return 'Mexican Peso';
      case Currency.MYR:
        return 'Malaysian Ringgit';
      case Currency.NZD:
        return 'New Zealand Dollar';
      case Currency.PHP:
        return 'Philippine Peso';
      case Currency.SGD:
        return 'Singapore Dollar';
      case Currency.THB:
        return 'Thai Baht';
      case Currency.ZAR:
        return 'South African Rand';
    }
  }

  String get symbol => toString().split('.').last;
}

String formatCurrency(double budget, Currency currency) {
  try {
    final format = NumberFormat.simpleCurrency(
      locale: 'en_US',
      name: currency.symbol,
      decimalDigits: budget == budget.roundToDouble() ? 0 : 2,
    );
    return format.format(budget);
  } catch (e) {
    return '$currency $budget';
  }
}

double metersToPixels(double meters, double latitude, double zoom) {
  final earthCircumference = 40075017.0; // in meters
  final latitudeRadians = latitude * (pi / 180);
  final metersPerPixel =
      earthCircumference * cos(latitudeRadians) / (256 * pow(2, zoom));
  return meters / metersPerPixel;
}
