import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/api/client.dart';
import 'package:mobile/api/messages.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/types/notification.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/pusher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCookieJar();
  await initPusher();
  final pusher = usePusher();

  final sharedPrefs = await SharedPreferences.getInstance();
  final messagesProvider = MessagesProvider(); // <-- Add this

  final userChannel = pusher.subscribe(
    'private-user-${sharedPrefs.getInt('userId')}',
  );
  userChannel.bind('new-notification', (event) {
    try {
      NotificationData notification = NotificationData.fromJson(event);
      if (notification.type == NotificationType.NEW_MESSAGE) {
        messagesProvider.loadMessages();
      }
    } on Exception catch (e) {
      print(e.toString());
    }

  });

  useApi().interceptors.add(DomainRewriteInterceptor('10.0.2.2'));
  runApp(

    ChangeNotifierProvider.value(
      value: messagesProvider,
      child: const MyApp(),
    ),
  );}

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
    );
  }
}
