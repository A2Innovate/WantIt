import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:mobile/utils/extensions.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../stores/client.dart';
import '../types/user.dart';

class SessionCard extends StatelessWidget {
  final UserSession session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final current = Provider.of<UserProvider>(context).current!;
    final isCurrent = current.sessionId == session.id;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    FlutterI18n.translate(
                      context,
                      'session_label',
                      translationParams: {"id": session.id.toString()},
                    ),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      FlutterI18n.translate(context, 'current_session'),
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () async {
                      try {
                        final client = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        await useApi().delete("/auth/session/${session.id}");
                        client.fetchSessions();
                      } catch (e) {
                        // ignore
                      }
                    },
                    child: Text(
                      FlutterI18n.translate(context, 'revoke'),
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${context.translate("expires_at")} ${DateFormat.MMMd().format(session.expiresAt)}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.public, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  session.ip ?? FlutterI18n.translate(context, 'unknown_ip'),
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
