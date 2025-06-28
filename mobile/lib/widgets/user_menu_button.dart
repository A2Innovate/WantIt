import 'package:flutter/material.dart';
import 'package:mobile/pages/sign_in.dart';
import 'package:mobile/pages/sign_up.dart';
import 'package:mobile/pages/profile.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../pages/settings.dart';
import '../providers/user_provider.dart';

class UserMenuButton extends StatefulWidget {
  const UserMenuButton({super.key});

  @override
  State<UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<UserMenuButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    var localizedStrings = AppLocalizations.of(context)!;
    final user = provider.current;
    final loggedIn = user != null;

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
              localizedStrings.sign_in,
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
              localizedStrings.sign_up,
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
            MaterialPageRoute(builder: (_) => ProfilePage()),
          );
        } else if (value == 1) {
          // TODO: Navigate to Settings page
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Go to Settings')));
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        } else if (value == 2) {
          // Logout
          await provider.logout();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logged out')));
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 0, child: Text(localizedStrings.profile)),
        PopupMenuItem(value: 1, child: Text(localizedStrings.settings)),
        PopupMenuItem(value: 2, child: Text(localizedStrings.logout)),
      ],
    );
  }
}
