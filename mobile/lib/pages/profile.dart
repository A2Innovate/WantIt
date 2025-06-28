import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final current = Provider.of<UserProvider>(context).current;
    final appLocalizations = AppLocalizations.of(context)!;

    if (current == null) {
      if (mounted) {
        Future.microtask(() => Navigator.pop(context));
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.profile)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                (current.username.isNotEmpty)
                    ? current.username[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              current.username,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
