import 'package:flutter/material.dart';
import 'package:mobile/pages/sign_in.dart';
import 'package:mobile/pages/sign_up.dart';
import 'package:mobile/pages/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/settings.dart';

class UserMenuButton extends StatefulWidget {
  const UserMenuButton({super.key});

  @override
  State<UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<UserMenuButton> {
  bool _loggedIn = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionIdExists = prefs.containsKey('sessionId');
    final username = prefs.getString('name') ?? '';

    setState(() {
      _loggedIn = sessionIdExists;
      _username = username;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionId');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('currency');
    await prefs.remove('isAdmin');
    setState(() {
      _loggedIn = false;
      _username = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loggedIn) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
              _loadUserData();
            },
            child: const Text('Sign In', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              );
              _loadUserData();
            },
            child: const Text('Sign Up', style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    }

    return PopupMenuButton<int>(
      tooltip: 'User menu',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          _username.isNotEmpty ? _username : '?',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      onSelected: (value) async {
        if (value == 0) {
          // TODO: Navigate to Profile page
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          );
        } else if (value == 1) {
          // TODO: Navigate to Settings page
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Go to Settings')));
          final settings = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
          if (settings == true) {
            _loadUserData(); // Refresh username after return
          }
        } else if (value == 2) {
          // Logout
          await _logout();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logged out')));
          }
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 0, child: Text('Profile')),
        PopupMenuItem(value: 1, child: Text('Settings')),
        PopupMenuItem(value: 2, child: Text('Logout')),
      ],
    );
  }
}
