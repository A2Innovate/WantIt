import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/utils/extensions.dart';

// ignore_for_file: constant_identifier_names
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
  String localizedName(BuildContext context) {
    return context.translate('currency_${symbol.toLowerCase()}_name');
  }

  String get symbol => toString().split('.').last;
}

String formatCurrency(
  double budget,
  Currency currency, {
  String locale = 'en_US',
}) {
  try {
    final format = NumberFormat.simpleCurrency(
      locale: locale,
      name: currency.symbol,
      decimalDigits: 2,
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
