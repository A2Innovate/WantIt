import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/types/user.dart';
import 'package:mobile/utils/extensions.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class SessionCard extends StatelessWidget {
  final UserSession session;
  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final current = Provider.of<UserProvider>(context).current!;
    return Container(
      width: 350,
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                FlutterI18n.translate(
                  context,
                  'session_label',
                  translationParams: {"id": session.id.toString()},
                ),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Text('•'),
              SizedBox(width: 8),
              Text(
                "${context.translate("expires_at")} ${DateFormat.MMMd().format(session.expiresAt)}",
              ),
              //
              Spacer(),
              if (current.sessionId == session.id)
                Text(
                  FlutterI18n.translate(context, 'current_session'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              else
                MaterialButton(
                  onPressed: () async {
                    final client = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    );
                    await useApi().delete("/auth/session/${session.id}");
                    client.fetchSessions();
                  },
                  child: Text(FlutterI18n.translate(context, 'revoke')),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(session.ip),
        ],
      ),
    );
  }
}
