import 'package:flutter/material.dart';
import 'package:mobile/pages/request_detail_page.dart';
import 'package:mobile/providers/notification_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/sign_in.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/widgets/deep_link_handler.dart';
import 'package:provider/provider.dart';
import 'stores/pusher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initCookieJar();
  useApi().interceptors.add(
    DomainRewriteInterceptor('three-ghosts-pay.loca.lt'),
  );
  final messagesProvider = MessagesProvider();
  final notificationProvider = NotificationProvider();
  final userProvider = UserProvider();
  await userProvider.fetchUser();
  if (userProvider.current != null) {
    final int userId = userProvider.current!.id;
    final pusherInitialized = await initPusher(userId, messagesProvider);
    if (!pusherInitialized) {
      print('Warning: Failed to initialize Pusher client');
    }
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MessagesProvider>.value(value: messagesProvider),
        ChangeNotifierProvider<NotificationProvider>.value(
          value: notificationProvider,
        ),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    );
  }
}
