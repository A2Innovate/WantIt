import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/pages/request_detail_page.dart';
import 'package:mobile/providers/notification_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/sign_in.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/widgets/deep_link_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'stores/pusher.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCookieJar();
  useApi().interceptors.add(
    DomainRewriteInterceptor('three-ghosts-pay.loca.lt'),
  );
  final messagesProvider = MessagesProvider();
  final notificationProvider = NotificationProvider();
  final userProvider = UserProvider();
  await userProvider.fetchUser();

  final prefs = await SharedPreferences.getInstance();
  var languageCode = "en";
  if (prefs.containsKey('language_code')) {
    languageCode = prefs.getString('language_code')!;
 }
  timeago.setLocaleMessages('pl', timeago.PlMessages());


  final int userId = userProvider.current?.id ?? -1;
  final pusherInitialized = await initPusher(userId, messagesProvider);
  if (!pusherInitialized) {
    print('Warning: Failed to initialize Pusher client');
  }
  final _flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: false,
      fallbackFile: 'en',
      basePath: 'assets/i18n',
      forcedLocale: Locale(languageCode),
    ),
    missingTranslationHandler: (key, locale) {
      print("--- Missing Key: $key, languageCode: ${locale?.languageCode}");
    },
  );

  // Load translations initially
  _flutterI18nDelegate.load(const Locale('en'));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MessagesProvider>.value(value: messagesProvider),
        ChangeNotifierProvider<NotificationProvider>.value(
          value: notificationProvider,
        ),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        // ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
      ],
      child: MyApp(flutterI18nDelegate: _flutterI18nDelegate)),
  );
}

class MyApp extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;
  const MyApp({super.key, required this.flutterI18nDelegate});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WantIt',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.amberAccent,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.amberAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const DeepLinkHandler(),
      debugShowCheckedModeBanner: false,
      routes: {'/main': (context) => const MainPage()},
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'request') {
          final requestId = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (_) => RequestDetailPage(requestId: int.parse(requestId)),
          );
        }
        if (uri.pathSegments[0] == 'signin') {
          final args = settings.arguments;
          if (args is! Map<String, dynamic>) {
            return MaterialPageRoute(builder: (_) => SignInPage());
          }
          return MaterialPageRoute(
            builder: (_) => SignInPage(queryParameters: args),
          );
        }
        return MaterialPageRoute(builder: (_) => const MainPage());
      },
      supportedLocales: const [Locale('en'), Locale('pl')],
      localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // locale: localeProvider.locale,
    );
  }
}

// class _MyAppState extends State<MyApp> {
//   late FlutterI18nDelegate _flutterI18nDelegate;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // _flutterI18nDelegate = FlutterI18nDelegate(
//     //   translationLoader: FileTranslationLoader(
//     //     useCountryCode: false,
//     //     fallbackFile: 'en',
//     //     basePath: 'assets/i18n',
//     //   ),
//     //   missingTranslationHandler: (key, locale) {
//     //     print("--- Missing Key: $key, languageCode: ${locale?.languageCode}");
//     //   },
//     // );
//     //
//     // // Load translations initially
//     // _flutterI18nDelegate.load(const Locale('en'));
//   }
//
//   @override
//
// }
