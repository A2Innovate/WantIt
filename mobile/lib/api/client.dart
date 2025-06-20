// lib/api/client.dart
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'currencies.dart';

final CookieJar cookieJar = CookieJar();

final Dio apiClient = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api'))
  ..interceptors.add(DomainRewriteInterceptor('10.0.2.2'));

Dio useApi() {
  // print(getRates());
  return apiClient;
}
// class DomainRewriteInterceptor extends Interceptor {
//   final String desiredDomain;
//
//   DomainRewriteInterceptor(this.desiredDomain);
//
//   List<String> cookies = [];
//
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     final headers = response.headers;
//     final setCookieHeaders = headers.map['set-cookie'];
//     if (setCookieHeaders != null) {
//       cookies = setCookieHeaders;
//     }
//     handler.next(response);
//   }
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     options.headers["cookie"] =  cookies;
//     handler.next(options);
//
//   }
// }

class DomainRewriteInterceptor extends Interceptor {
  final String desiredDomain;

  DomainRewriteInterceptor(this.desiredDomain);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final headers = response.headers;
    final setCookieHeaders = headers.map['set-cookie'];
    if (setCookieHeaders != null) {
      final uri = response.requestOptions.uri;

      final cookies = setCookieHeaders.map((str) {
        // Basic parse: extract name and value before ';'
        final cookieString = str.split(';').first;
        final nameValue = cookieString.split('=');
        print(cookieString);

        return Cookie(
          nameValue[0].trim(),
          nameValue.sublist(1).join('=').trim(),
        )..domain = desiredDomain;
      }).toList();

      // Save cookies to cookieJar for future requests
      await cookieJar.saveFromResponse(uri, cookies);
    }
    handler.next(response);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Load cookies from jar for the request URL
    final cookies = await cookieJar.loadForRequest(options.uri);

    if (cookies.isNotEmpty) {
      // Build "key1=val1; key2=val2" cookie header string
      final cookieHeader = cookies
          .map((c) => '${c.name}=${c.value}')
          .join('; ');
      options.headers['cookie'] = cookieHeader;
    }
    print(cookies);
    handler.next(options);
  }
}
