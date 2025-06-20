import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // <--- import Riverpod
import 'package:mobile/pages/persistent_search_page.dart';

void main() {
  runApp(
    const ProviderScope(  // <--- Wrap app in ProviderScope
      child: MyApp(),
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
      home: const PersistentSearchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
