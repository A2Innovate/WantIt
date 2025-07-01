import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/pages/sign_in.dart';
import 'package:mobile/pages/sign_up.dart';
import 'package:mobile/pages/profile.dart';
import 'package:provider/provider.dart';

import '../pages/settings.dart';
import '../providers/user_provider.dart';

class UserMenuButton extends StatefulWidget {
  const UserMenuButton({super.key});

  @override
  State<UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<UserMenuButton> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final user = provider.current;
    final loggedIn = user != null;

    // Fetch translations using flutter_i18n
    final signInText = FlutterI18n.translate(context, 'sign_in');
    final signUpText = FlutterI18n.translate(context, 'sign_up');
    final profileText = FlutterI18n.translate(context, 'profile');
    final settingsText = FlutterI18n.translate(context, 'settings');
    final logoutText = FlutterI18n.translate(context, 'sign_out');
    final loggedOutMsg = FlutterI18n.translate(context, 'validation_logged_out_successfully');

    if (!loggedIn) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            },
            child: Text(
              signInText,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              );
            },
            child: Text(
              signUpText,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<int>(
      tooltip: 'User menu',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          user.username.isNotEmpty ? user.username : '?',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      onSelected: (value) async {
        if (value == 0) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        } else if (value == 1) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        } else if (value == 2) {
          await provider.logout();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(loggedOutMsg)));
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 0, child: Text(profileText)),
        PopupMenuItem(value: 1, child: Text(settingsText)),
        PopupMenuItem(value: 2, child: Text(logoutText)),
      ],
    );
  }
}
