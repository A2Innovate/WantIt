class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'http://10.0.2.2:8000',
    defaultValue: 'https://api.atmudia.xyz',
  );
  static const String pusherHost = String.fromEnvironment(
    'PUSHER_HOST',
    defaultValue: 'soketi.atmudia.xyz',
    // defaultValue: '192.168.1.135',
  );
  static const String pusherAppKey = String.fromEnvironment(
    'PUSHER_APP_KEY',
    defaultValue: 'wantit-key',
  );
  static const String s3Bucket = String.fromEnvironment(
    'S3_BUCKET',
    defaultValue: 'mybucket',
  );
  static const String s3Endpoint = String.fromEnvironment(
    'S3_ENDPOINT',
    defaultValue: 'http://172.21.0.2:9000',
  );
}
