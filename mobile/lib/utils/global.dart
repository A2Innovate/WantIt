import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;

    switch (this) {
      case Currency.USD:
        return loc.currency_usd_name;
      case Currency.PLN:
        return loc.currency_pln_name;
      case Currency.EUR:
        return loc.currency_eur_name;
      case Currency.GBP:
        return loc.currency_gbp_name;
      case Currency.JPY:
        return loc.currency_jpy_name;
      case Currency.BGN:
        return loc.currency_bgn_name;
      case Currency.CZK:
        return loc.currency_czk_name;
      case Currency.DKK:
        return loc.currency_dkk_name;
      case Currency.HUF:
        return loc.currency_huf_name;
      case Currency.RON:
        return loc.currency_ron_name;
      case Currency.SEK:
        return loc.currency_sek_name;
      case Currency.CHF:
        return loc.currency_chf_name;
      case Currency.ISK:
        return loc.currency_isk_name;
      case Currency.NOK:
        return loc.currency_nok_name;
      case Currency.TRY:
        return loc.currency_try_name;
      case Currency.AUD:
        return loc.currency_aud_name;
      case Currency.BRL:
        return loc.currency_brl_name;
      case Currency.CAD:
        return loc.currency_cad_name;
      case Currency.CNY:
        return loc.currency_cny_name;
      case Currency.HKD:
        return loc.currency_hkd_name;
      case Currency.IDR:
        return loc.currency_idr_name;
      case Currency.ILS:
        return loc.currency_ils_name;
      case Currency.INR:
        return loc.currency_inr_name;
      case Currency.KRW:
        return loc.currency_krw_name;
      case Currency.MXN:
        return loc.currency_mxn_name;
      case Currency.MYR:
        return loc.currency_myr_name;
      case Currency.NZD:
        return loc.currency_nzd_name;
      case Currency.PHP:
        return loc.currency_php_name;
      case Currency.SGD:
        return loc.currency_sgd_name;
      case Currency.THB:
        return loc.currency_thb_name;
      case Currency.ZAR:
        return loc.currency_zar_name;
    }
  }

  String get symbol => toString().split('.').last;
}

String formatCurrency(double budget, Currency currency) {
  try {
    final format = NumberFormat.simpleCurrency(
      locale: 'en_US',
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
