import 'package:flutter/material.dart';
import 'package:mobile/pages/chat_details.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/message_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async'; // For Timer

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// ... other imports

class _ChatPageState extends State<ChatPage> {
  bool _loggedIn = false;
  bool _loading = true;
  Timer? _sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _startSessionMonitor();
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLoginStatus({bool refresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionExists = prefs.containsKey('sessionId');

    if (refresh && mounted && sessionExists != _loggedIn) {
      setState(() {
        _loggedIn = sessionExists;
      });
    }

    if (!refresh && sessionExists && mounted) {
      await Provider.of<MessagesProvider>(context, listen: false)
          .fetchRefreshMessages();
    }

    if (mounted) {
      setState(() {
        _loggedIn = sessionExists;
        _loading = false;
      });
    }
  }

  void _startSessionMonitor() {
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkLoginStatus(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessagesProvider>(context);
    final lastMessages = provider.messages;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_loggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'You must be signed in to view your chats.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signin');
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.fetchRefreshMessages,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Chats',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: lastMessages.isEmpty
                  ? const Center(child: Text('No messages yet.'))
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
                            builder: (_) =>
                                ChatDetailsPage(user: message.person),
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
                                message.person.username[1].toUpperCase(),
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
                            Text(timeago.format(message.createdAt)),
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
