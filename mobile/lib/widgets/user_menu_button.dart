import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/pages/sign_in.dart';
import 'package:mobile/pages/sign_up.dart';
import 'package:mobile/pages/profile.dart';
import 'package:mobile/utils/extensions.dart';
import 'package:provider/provider.dart';

import '../pages/admin_page.dart';
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
            child: Text(context.translate("sign_in")),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              );
            },
            child: Text(context.translate("sign_up")),
          ),
        ],
      );
    }

    return PopupMenuButton<int>(
      tooltip: 'User Menu Button',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          user.username.isNotEmpty ? user.username : '?',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      onSelected: (value) async {
        if (value == 0) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage(userId: user.id)),
          );
        }
        else if (value == 1) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminPage()),
          );
        }
        else if (value == 2) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        } else if (value == 3) {
          await provider.logout();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(context.translate('validation_logged_out_successfully'))));
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 0, child: Text(context.translate('profile'))),
        if (loggedIn && user.isAdmin!)
          PopupMenuItem(
            value: 1,
            child: Text(FlutterI18n.translate(context, 'admin')),
          ),
        PopupMenuItem(value: 2, child: Text(context.translate('settings'))),
        PopupMenuItem(value: 3, child: Text(context.translate('sign_out'))),
      ],
    );
  }
}