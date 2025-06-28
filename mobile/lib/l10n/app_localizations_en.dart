// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sign_in => 'Sign In';

  @override
  String get sign_up => 'Sign Up';

  @override
  String get logout => 'Logout';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get dont_have_an_account => 'Don\'t have an account?';

  @override
  String get already_have_an_account => 'Already have an account?';

  @override
  String get create_an_account => 'Create an account';

  @override
  String get forgot_password => 'Forgot your password?';

  @override
  String get reset_password => 'Reset Password';

  @override
  String get reset_password_desc =>
      'Enter your email to receive a password reset link.';

  @override
  String get passwords_dont_match => 'Passwords don\'t match';

  @override
  String get send_reset_link => 'Send Reset Link';

  @override
  String get reset_link_sent => 'Reset link sent! Please check your email.';

  @override
  String get continue_with_google => 'Continue with Google';

  @override
  String get home => 'Home';

  @override
  String get back_to_home => 'Back to Home';

  @override
  String get search_items => 'Search items...';

  @override
  String get no_results => 'No results found';

  @override
  String get chat => 'Chat';

  @override
  String get auth_required_for_chat =>
      'You must be signed in to view your chats.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get edited => 'Edited';

  @override
  String get delete => 'Delete';

  @override
  String get location => 'Location';

  @override
  String get location_local => 'Local';

  @override
  String get location_global => 'Global';

  @override
  String get what_do_you_want => 'What do you want?';

  @override
  String get negotiable => 'Negotiable';

  @override
  String get new_request => 'New Request';

  @override
  String get edit_request => 'Edit Request';

  @override
  String get request_details => 'Request Details';

  @override
  String request_not_found(Object requestId) {
    return 'Can\'t find request $requestId!';
  }

  @override
  String get deletion_confirmation_request =>
      'Are you sure you want to delete this request? This action cannot be undone';

  @override
  String get offers => 'Offers';

  @override
  String get new_offer => 'New offer';

  @override
  String get edit_offer => 'Edit offer';

  @override
  String get deletion_confirmation_offer =>
      'Are you sure you want to delete this offer? This action cannot be undone.';

  @override
  String get deletion_confirmation_comment =>
      'Are you sure you want to delete this comment?';

  @override
  String get current_images => 'Current Images';

  @override
  String get no_images => 'No current images';

  @override
  String get new_images => 'New Images';

  @override
  String get tap_to_select_image => 'Tap to select image';

  @override
  String get max_offer_images => 'One offer can have up to 10 images.';

  @override
  String get max_image_size =>
      'At least one of your images is too large, max size is 5MB.';

  @override
  String get unable_to_load_map => 'Unable to load map';

  @override
  String get newest_first => 'Newest first';

  @override
  String get oldest_first => 'Oldest first';

  @override
  String get cheapest_first => 'Cheapest first';

  @override
  String get expensive_first => 'Expensive first';

  @override
  String get network_error => 'Network error. Please check your connection';

  @override
  String get unknown_error => 'Unknown error. Please try again later';

  @override
  String get invalid_response_format => 'Invalid response format';

  @override
  String get failed_to_fetch_items => 'Failed to fetch items';

  @override
  String get confirm_deletion => 'Confirm Deletion';

  @override
  String get currency_usd_name => 'United States dollar';

  @override
  String get currency_pln_name => 'Polish złoty';

  @override
  String get currency_eur_name => 'Euro';

  @override
  String get currency_gbp_name => 'British Pound Sterling';

  @override
  String get currency_jpy_name => 'Japanese Yen';

  @override
  String get currency_bgn_name => 'Bulgarian Lev';

  @override
  String get currency_czk_name => 'Czech koruna';

  @override
  String get currency_dkk_name => 'Danish Krone';

  @override
  String get currency_huf_name => 'Hungarian Forint';

  @override
  String get currency_ron_name => 'Romanian Leu';

  @override
  String get currency_sek_name => 'Swedish Krona';

  @override
  String get currency_chf_name => 'Swiss Franc';

  @override
  String get currency_isk_name => 'Icelandic Krona';

  @override
  String get currency_nok_name => 'Norwegian Krone';

  @override
  String get currency_try_name => 'Turkish Lira';

  @override
  String get currency_aud_name => 'Australian Dollar';

  @override
  String get currency_brl_name => 'Brazilian Real';

  @override
  String get currency_cad_name => 'Canadian Dollar';

  @override
  String get currency_cny_name => 'Chinese Yuan';

  @override
  String get currency_hkd_name => 'Hong Kong Dollar';

  @override
  String get currency_idr_name => 'Indonesian Rupiah';

  @override
  String get currency_ils_name => 'Israeli Shekel';

  @override
  String get currency_inr_name => 'Indian Rupee';

  @override
  String get currency_krw_name => 'South Korean Won';

  @override
  String get currency_mxn_name => 'Mexican Peso';

  @override
  String get currency_myr_name => 'Malaysian Ringgit';

  @override
  String get currency_nzd_name => 'New Zealand Dollar';

  @override
  String get currency_php_name => 'Philippine Peso';

  @override
  String get currency_sgd_name => 'Singapore Dollar';

  @override
  String get currency_thb_name => 'Thai Baht';

  @override
  String get currency_zar_name => 'South African Rand';
}
