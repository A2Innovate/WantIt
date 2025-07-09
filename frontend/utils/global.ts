export const CURRENCIES_NAMES = [
  { currency: 'USD', name: 'currency_usd_name' },
  { currency: 'PLN', name: 'currency_pln_name' },
  { currency: 'EUR', name: 'currency_eur_name' },
  { currency: 'GBP', name: 'currency_gbp_name' },
  { currency: 'JPY', name: 'currency_jpy_name' },
  { currency: 'BGN', name: 'currency_bgn_name' },
  { currency: 'CZK', name: 'currency_czk_name' },
  { currency: 'DKK', name: 'currency_dkk_name' },
  { currency: 'HUF', name: 'currency_huf_name' },
  { currency: 'RON', name: 'currency_ron_name' },
  { currency: 'SEK', name: 'currency_sek_name' },
  { currency: 'CHF', name: 'currency_chf_name' },
  { currency: 'ISK', name: 'currency_isk_name' },
  { currency: 'NOK', name: 'currency_nok_name' },
  { currency: 'TRY', name: 'currency_try_name' },
  { currency: 'AUD', name: 'currency_aud_name' },
  { currency: 'BRL', name: 'currency_brl_name' },
  { currency: 'CAD', name: 'currency_cad_name' },
  { currency: 'CNY', name: 'currency_cny_name' },
  { currency: 'HKD', name: 'currency_hkd_name' },
  { currency: 'IDR', name: 'currency_idr_name' },
  { currency: 'ILS', name: 'currency_ils_name' },
  { currency: 'INR', name: 'currency_inr_name' },
  { currency: 'KRW', name: 'currency_krw_name' },
  { currency: 'MXN', name: 'currency_mxn_name' },
  { currency: 'MYR', name: 'currency_myr_name' },
  { currency: 'NZD', name: 'currency_nzd_name' },
  { currency: 'PHP', name: 'currency_php_name' },
  { currency: 'SGD', name: 'currency_sgd_name' },
  { currency: 'THB', name: 'currency_thb_name' },
  { currency: 'ZAR', name: 'currency_zar_name' }
];

export const CURRENCIES = CURRENCIES_NAMES.map((currency) => currency.currency);

export const NOTIFICATION_TYPES = [
  'NEW_OFFER',
  'NEW_MESSAGE',
  'NEW_OFFER_COMMENT',
  'NEW_ALERT_MATCH',
  'OFFER_ACCEPTED'
];

export const COMPARISON_MODES = [
  {
    value: 'EQUALS',
    label: `Equal to`
  },
  {
    value: 'LESS_THAN',
    label: `Less than`
  },
  {
    value: 'LESS_THAN_OR_EQUAL_TO',
    label: `Less than or equal to`
  },
  {
    value: 'GREATER_THAN',
    label: `Greater than`
  },
  {
    value: 'GREATER_THAN_OR_EQUAL_TO',
    label: `Greater than or equal to`
  }
];

export const LOG_TYPES = [
  'USER_LOGIN',
  'USER_LOGIN_FAILURE',
  'USER_LOGOUT',
  'USER_REGISTRATION',
  'REQUEST_CREATE',
  'REQUEST_UPDATE',
  'REQUEST_DELETE',
  'OFFER_CREATE',
  'OFFER_UPDATE',
  'OFFER_DELETE',
  'RATELIMIT_HIT'
];
