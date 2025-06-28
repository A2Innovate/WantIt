// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get network_error => 'Network error. Please check your connection';

  @override
  String get search_items => 'Search items...';

  @override
  String get no_results => 'No results found';
}
