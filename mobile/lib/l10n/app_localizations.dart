import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dont_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dont_have_an_account;

  /// No description provided for @already_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_an_account;

  /// No description provided for @create_an_account.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get create_an_account;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgot_password;

  /// No description provided for @reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset_password;

  /// No description provided for @reset_password_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get reset_password_desc;

  /// No description provided for @passwords_dont_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwords_dont_match;

  /// No description provided for @send_reset_link.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get send_reset_link;

  /// No description provided for @reset_link_sent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent! Please check your email.'**
  String get reset_link_sent;

  /// No description provided for @continue_with_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continue_with_google;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @back_to_home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get back_to_home;

  /// No description provided for @search_items.
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get search_items;

  /// No description provided for @no_results.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get no_results;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @auth_required_for_chat.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to view your chats.'**
  String get auth_required_for_chat;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @location_local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get location_local;

  /// No description provided for @location_global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get location_global;

  /// No description provided for @what_do_you_want.
  ///
  /// In en, this message translates to:
  /// **'What do you want?'**
  String get what_do_you_want;

  /// No description provided for @negotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get negotiable;

  /// No description provided for @new_request.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get new_request;

  /// No description provided for @edit_request.
  ///
  /// In en, this message translates to:
  /// **'Edit Request'**
  String get edit_request;

  /// No description provided for @request_details.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get request_details;

  /// No description provided for @request_not_found.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find request {requestId}!'**
  String request_not_found(Object requestId);

  /// No description provided for @deletion_confirmation_request.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this request? This action cannot be undone'**
  String get deletion_confirmation_request;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @new_offer.
  ///
  /// In en, this message translates to:
  /// **'New offer'**
  String get new_offer;

  /// No description provided for @edit_offer.
  ///
  /// In en, this message translates to:
  /// **'Edit offer'**
  String get edit_offer;

  /// No description provided for @deletion_confirmation_offer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this offer? This action cannot be undone.'**
  String get deletion_confirmation_offer;

  /// No description provided for @deletion_confirmation_comment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get deletion_confirmation_comment;

  /// No description provided for @current_images.
  ///
  /// In en, this message translates to:
  /// **'Current Images'**
  String get current_images;

  /// No description provided for @no_images.
  ///
  /// In en, this message translates to:
  /// **'No current images'**
  String get no_images;

  /// No description provided for @new_images.
  ///
  /// In en, this message translates to:
  /// **'New Images'**
  String get new_images;

  /// No description provided for @tap_to_select_image.
  ///
  /// In en, this message translates to:
  /// **'Tap to select image'**
  String get tap_to_select_image;

  /// No description provided for @max_offer_images.
  ///
  /// In en, this message translates to:
  /// **'One offer can have up to 10 images.'**
  String get max_offer_images;

  /// No description provided for @max_image_size.
  ///
  /// In en, this message translates to:
  /// **'At least one of your images is too large, max size is 5MB.'**
  String get max_image_size;

  /// No description provided for @unable_to_load_map.
  ///
  /// In en, this message translates to:
  /// **'Unable to load map'**
  String get unable_to_load_map;

  /// No description provided for @newest_first.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newest_first;

  /// No description provided for @oldest_first.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldest_first;

  /// No description provided for @cheapest_first.
  ///
  /// In en, this message translates to:
  /// **'Cheapest first'**
  String get cheapest_first;

  /// No description provided for @expensive_first.
  ///
  /// In en, this message translates to:
  /// **'Expensive first'**
  String get expensive_first;

  /// No description provided for @network_error.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get network_error;

  /// No description provided for @unknown_error.
  ///
  /// In en, this message translates to:
  /// **'Unknown error. Please try again later'**
  String get unknown_error;

  /// No description provided for @invalid_response_format.
  ///
  /// In en, this message translates to:
  /// **'Invalid response format'**
  String get invalid_response_format;

  /// No description provided for @failed_to_fetch_items.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch items'**
  String get failed_to_fetch_items;

  /// No description provided for @confirm_deletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirm_deletion;

  /// No description provided for @currency_usd_name.
  ///
  /// In en, this message translates to:
  /// **'United States dollar'**
  String get currency_usd_name;

  /// No description provided for @currency_pln_name.
  ///
  /// In en, this message translates to:
  /// **'Polish złoty'**
  String get currency_pln_name;

  /// No description provided for @currency_eur_name.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currency_eur_name;

  /// No description provided for @currency_gbp_name.
  ///
  /// In en, this message translates to:
  /// **'British Pound Sterling'**
  String get currency_gbp_name;

  /// No description provided for @currency_jpy_name.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get currency_jpy_name;

  /// No description provided for @currency_bgn_name.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian Lev'**
  String get currency_bgn_name;

  /// No description provided for @currency_czk_name.
  ///
  /// In en, this message translates to:
  /// **'Czech koruna'**
  String get currency_czk_name;

  /// No description provided for @currency_dkk_name.
  ///
  /// In en, this message translates to:
  /// **'Danish Krone'**
  String get currency_dkk_name;

  /// No description provided for @currency_huf_name.
  ///
  /// In en, this message translates to:
  /// **'Hungarian Forint'**
  String get currency_huf_name;

  /// No description provided for @currency_ron_name.
  ///
  /// In en, this message translates to:
  /// **'Romanian Leu'**
  String get currency_ron_name;

  /// No description provided for @currency_sek_name.
  ///
  /// In en, this message translates to:
  /// **'Swedish Krona'**
  String get currency_sek_name;

  /// No description provided for @currency_chf_name.
  ///
  /// In en, this message translates to:
  /// **'Swiss Franc'**
  String get currency_chf_name;

  /// No description provided for @currency_isk_name.
  ///
  /// In en, this message translates to:
  /// **'Icelandic Krona'**
  String get currency_isk_name;

  /// No description provided for @currency_nok_name.
  ///
  /// In en, this message translates to:
  /// **'Norwegian Krone'**
  String get currency_nok_name;

  /// No description provided for @currency_try_name.
  ///
  /// In en, this message translates to:
  /// **'Turkish Lira'**
  String get currency_try_name;

  /// No description provided for @currency_aud_name.
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get currency_aud_name;

  /// No description provided for @currency_brl_name.
  ///
  /// In en, this message translates to:
  /// **'Brazilian Real'**
  String get currency_brl_name;

  /// No description provided for @currency_cad_name.
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get currency_cad_name;

  /// No description provided for @currency_cny_name.
  ///
  /// In en, this message translates to:
  /// **'Chinese Yuan'**
  String get currency_cny_name;

  /// No description provided for @currency_hkd_name.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Dollar'**
  String get currency_hkd_name;

  /// No description provided for @currency_idr_name.
  ///
  /// In en, this message translates to:
  /// **'Indonesian Rupiah'**
  String get currency_idr_name;

  /// No description provided for @currency_ils_name.
  ///
  /// In en, this message translates to:
  /// **'Israeli Shekel'**
  String get currency_ils_name;

  /// No description provided for @currency_inr_name.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get currency_inr_name;

  /// No description provided for @currency_krw_name.
  ///
  /// In en, this message translates to:
  /// **'South Korean Won'**
  String get currency_krw_name;

  /// No description provided for @currency_mxn_name.
  ///
  /// In en, this message translates to:
  /// **'Mexican Peso'**
  String get currency_mxn_name;

  /// No description provided for @currency_myr_name.
  ///
  /// In en, this message translates to:
  /// **'Malaysian Ringgit'**
  String get currency_myr_name;

  /// No description provided for @currency_nzd_name.
  ///
  /// In en, this message translates to:
  /// **'New Zealand Dollar'**
  String get currency_nzd_name;

  /// No description provided for @currency_php_name.
  ///
  /// In en, this message translates to:
  /// **'Philippine Peso'**
  String get currency_php_name;

  /// No description provided for @currency_sgd_name.
  ///
  /// In en, this message translates to:
  /// **'Singapore Dollar'**
  String get currency_sgd_name;

  /// No description provided for @currency_thb_name.
  ///
  /// In en, this message translates to:
  /// **'Thai Baht'**
  String get currency_thb_name;

  /// No description provided for @currency_zar_name.
  ///
  /// In en, this message translates to:
  /// **'South African Rand'**
  String get currency_zar_name;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
