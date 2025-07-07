import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/pages/chat_details.dart';
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

    final authRequiredText = FlutterI18n.translate(
      context,
      'auth_required_for_chat',
    );
    final signInLabel = FlutterI18n.translate(context, 'sign_in');
    final chatTitle = FlutterI18n.translate(context, 'chat');
    final chatsLabel = FlutterI18n.translate(context, 'chat');
    final noMessagesText = FlutterI18n.translate(context, 'no_messages_yet');

    if (userProvider.current == null) {
      return Scaffold(
        appBar: AppBar(title: Text(chatTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  authRequiredText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signin');
                  },
                  child: Text(signInLabel),
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
        title: Text(chatTitle),
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
                chatsLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: lastMessages.isEmpty
                  ? Center(child: Text(noMessagesText))
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
