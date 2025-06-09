export const CURRENCIES_NAMES = [
  { currency: 'USD', name: 'United States dollar' },
  { currency: 'PLN', name: 'Polish złoty' },
  { currency: 'EUR', name: 'Euro' },
  { currency: 'GBP', name: 'British Pound Sterling' },
  { currency: 'JPY', name: 'Japanese Yen' },
  { currency: 'BGN', name: 'Bulgarian Lev' },
  { currency: 'CZK', name: 'Czech koruna' },
  { currency: 'DKK', name: 'Danish Krone' },
  { currency: 'HUF', name: 'Hungarian Forint' },
  { currency: 'RON', name: 'Romanian Leu' },
  { currency: 'SEK', name: 'Swedish Krona' },
  { currency: 'CHF', name: 'Swiss Franc' },
  { currency: 'ISK', name: 'Icelandic Krona' },
  { currency: 'NOK', name: 'Norwegian Krone' },
  { currency: 'TRY', name: 'Turkish Lira' },
  { currency: 'AUD', name: 'Australian Dollar' },
  { currency: 'BRL', name: 'Brazilian Real' },
  { currency: 'CAD', name: 'Canadian Dollar' },
  { currency: 'CNY', name: 'Chinese Yuan' },
  { currency: 'HKD', name: 'Hong Kong Dollar' },
  { currency: 'IDR', name: 'Indonesian Rupiah' },
  { currency: 'ILS', name: 'Israeli Shekel' },
  { currency: 'INR', name: 'Indian Rupee' },
  { currency: 'KRW', name: 'South Korean Won' },
  { currency: 'MXN', name: 'Mexican Peso' },
  { currency: 'MYR', name: 'Malaysian Ringgit' },
  { currency: 'NZD', name: 'New Zealand Dollar' },
  { currency: 'PHP', name: 'Philippine Peso' },
  { currency: 'SGD', name: 'Singapore Dollar' },
  { currency: 'THB', name: 'Thai Baht' },
  { currency: 'ZAR', name: 'South African Rand' }
];

export const CURRENCIES = CURRENCIES_NAMES.map((currency) => currency.currency);

export const NOTIFICATION_TYPES = [
  'NEW_OFFER',
  'NEW_MESSAGE',
  'NEW_OFFER_COMMENT',
  'NEW_ALERT_MATCH'
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
