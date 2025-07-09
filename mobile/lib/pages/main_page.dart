import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'persistent_search_page.dart';
import 'chat_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [PersistentSearchPage(), ChatPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeLabel = FlutterI18n.translate(context, 'home');
    final chatLabel = FlutterI18n.translate(context, 'chat');

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: homeLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: chatLabel,
          ),
        ],
      ),
    );
  }
}
