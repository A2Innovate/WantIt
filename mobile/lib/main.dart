import 'package:flutter/material.dart';
import 'package:mobile/pages/persistent_search_page.dart';

void main() {
  runApp(MyApp());
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
