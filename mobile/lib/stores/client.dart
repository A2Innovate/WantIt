import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:mobile/api_config.dart';
import 'package:path_provider/path_provider.dart';

final Dio apiClient = Dio(BaseOptions(baseUrl: "${ApiConfig.baseUrl}/api"));

PersistCookieJar? cookieJar;

Future<void> initCookieJar() async {
  final dir = await getApplicationDocumentsDirectory();
  cookieJar = PersistCookieJar(storage: FileStorage("${dir.path}/.cookies/"));
}

Dio useApi() {
  return apiClient;
}

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

        return Cookie(
          nameValue[0].trim(),
          nameValue.sublist(1).join('=').trim(),
        )..domain = desiredDomain;
      }).toList();
      // Save cookies to cookieJar for future requests
      if (cookieJar != null) {
        await cookieJar!.saveFromResponse(uri, cookies);
      }
    }
    handler.next(response);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Load cookies from jar for the request URL
    final cookies = await cookieJar!.loadForRequest(options.uri);

    if (cookies.isNotEmpty) {
      // Build "key1=val1; key2=val2" cookie header string
      final cookieHeader = cookies
          .map((c) => '${c.name}=${c.value}')
          .join('; ');
      options.headers['cookie'] = cookieHeader;
    }
    handler.next(options);
  }
}
