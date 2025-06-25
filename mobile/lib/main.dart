import 'package:flutter/material.dart';
import 'package:mobile/api/client.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/sign_in.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/pusher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCookieJar();
  final messagesProvider = MessagesProvider();
  final sharedPrefs = await SharedPreferences.getInstance();
  final int? userId = sharedPrefs.getInt('userId');
  if (userId != null) {
    final pusherInitialized = await initPusher(userId, messagesProvider);
    if (!pusherInitialized) {
      print('Warning: Failed to initialize Pusher client');
    }
  }
  useApi().interceptors.add(DomainRewriteInterceptor('10.0.2.2'));
  runApp(
    ChangeNotifierProvider.value(value: messagesProvider, child: const MyApp()),
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
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
      routes: {'/signin': (context) => const SignInPage()},
    );
  }
}
