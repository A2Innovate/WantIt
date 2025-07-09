class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.atmudia.xyz',
  );
  static const String pusherHost = String.fromEnvironment(
    'PUSHER_HOST',
    defaultValue: 'soketi.atmudia.xyz',
  );
  static const String pusherAppKey = String.fromEnvironment(
    'PUSHER_APP_KEY',
    defaultValue: 'wantit-key',
  );
  static const String s3Bucket = String.fromEnvironment(
    'S3_BUCKET',
    defaultValue: 'wantit',
  );
  static const String s3Endpoint = String.fromEnvironment(
    'S3_ENDPOINT',
    defaultValue: 'https://s3.atmudia.xyz',
  );
}
