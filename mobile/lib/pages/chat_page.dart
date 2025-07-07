import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/pages/chat_details.dart';
import 'package:mobile/utils/extensions.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/user_provider.dart';
import 'dart:async';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        if (Provider.of<UserProvider>(context, listen: false).current != null) {
          Provider.of<MessagesProvider>(
            context,
            listen: false,
          ).fetchRefreshMessages();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessagesProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.current == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.translate("chat"))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.translate("auth_required_for_chat"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signin');
                  },
                  child: Text(context.translate("sign_in")),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final lastMessages = messageProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate("chat")),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: messageProvider.fetchRefreshMessages,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                context.translate("chat"),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: lastMessages.isEmpty
                  ? Center(child: Text(context.translate("no_messages_yet")))
                  : ListView.builder(
                      itemCount: lastMessages.length,
                      itemBuilder: (context, index) {
                        final message = lastMessages[index];
                        return GestureDetector(
                          onTap: () {
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailsPage(
                                    userId: message.person.id,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 10.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    child: Text(
                                      message.person.username.length > 1
                                          ? message.person.username[1]
                                                .toUpperCase()
                                          : message.person.username[0]
                                                .toUpperCase(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('@${message.person.username}'),
                                        Text(message.content),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    timeago.format(
                                      message.createdAt,
                                      locale: FlutterI18n.currentLocale(
                                        context,
                                      )!.languageCode,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
