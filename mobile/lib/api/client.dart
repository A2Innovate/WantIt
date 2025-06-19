// lib/api/client.dart
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

final cookieJar =
    CookieJar(); // or PersistCookieJar() for saving between app launches

Dio useApi() {
  final dio = Dio(
    BaseOptions(
      // baseUrl: 'http://10.0.2.2:8000/api',
      baseUrl: 'https://api.wantit.aleksander.cc/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(CookieManager(cookieJar));

  return dio;
}
