import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/stores/pusher.dart';
import 'package:mobile/types/chat.dart';
import 'package:provider/provider.dart';
import 'package:pusher_client_socket/channels/channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../l10n/app_localizations.dart';
import '../providers/message_provider.dart';
import '../schemas/chat.dart';
import '../types/messages.dart';

class ChatDetailsPage extends StatefulWidget {
  final Person user;
  const ChatDetailsPage({super.key, required this.user});

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  Chat? chat;
  bool isLoading = true;
  String? errorMessage;
  String? errorFormMessage;
  String? _currentName;
  String? _currentUsername;
  int? _currentId;
  Channel? _pusherChannel;
  Timer? _timer;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> getChatResponse() async {
    try {
      final response = await useApi().get('/chat/${widget.user.id}');
      setState(() {
        chat = Chat.fromJson(response.data);
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load chat. Please try again';
      });
    }
  }

  Future<void> _loadProfileSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentName = prefs.getString('name');
      _currentUsername = prefs.getString('username');
      _currentId = prefs.getInt('userId');
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSend() async {
    setState(() {
      errorFormMessage = null;
      errorMessage = null;
    });

    final value = {'content': _messageController.text.trim()};

    final result = await sendChatMessageSchema.tryParseAsync(value);
    if (!result.success) {
      for (final err in result.errors.entries) {
        final errorValue = err.value;
        if (errorValue is Map && errorValue.isNotEmpty) {
          errorFormMessage =
              errorValue.values.first?.toString() ?? 'Validation error';
        } else {
          errorFormMessage = 'Invalid ${err.key}';
        }
      }
      return;
    }

    try {
      final response = await useApi().post(
        '/chat/${widget.user.id}',
        data: value,
      );

      _messageController.clear();
      await getChatResponse();
      final message = Message.fromJson(response.data);
      if (mounted) {
        Provider.of<MessagesProvider>(context, listen: false).upsertLastMessage(
          widget.user.id,
          _currentName!,
          _currentUsername!,
          message.createdAt,
          message.content,
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to send message: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getChatResponse();
    _initialize();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _timer?.cancel();
    _pusherChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _loadProfileSettings();
    _subscribeToPusher();
  }

  void _subscribeToPusher() {
    if (_currentId == null) return;

    _pusherChannel = usePusher().subscribe(
      'private-user-$_currentId-chat-${widget.user.id}',
    );
    _pusherChannel?.bind('new-message', (event) {
      final message = Message.fromJson(event);

      setState(() {
        chat?.messages.add(message);
        scrollToBottom();
        Provider.of<MessagesProvider>(context, listen: false).upsertLastMessage(
          widget.user.id,
          _currentName ?? '',
          _currentUsername ?? '',
          message.createdAt,
          message.content,
        );
      });
    });
    _pusherChannel?.bind('update-message', (event) {
      final int? id = event['id'] as int?;
      final message = chat?.messages.firstWhereOrNull((msg) => msg.id == id);
      if (message != null) {
        setState(() {
          message.applyPartialUpdate(event);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 24, child: Text(widget.user.name[0])),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        '@${widget.user.username}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(child: Text(errorMessage!))
                  : chat == null || chat!.messages.isEmpty
                  ? const Center(child: Text('No messages yet'))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: chat!.messages.length,
                      itemBuilder: (context, index) {
                        final msg = chat!.messages[index];
                        final isMe = msg.senderId != widget.user.id;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width *
                                  0.8, // Adjusted width
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  msg.content,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                if (msg.edited)
                                  Text(
                                    'Edited',
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  timeago.format(msg.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          errorText: errorFormMessage,
                        ),
                        onSubmitted: (value) {
                          _onSend();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () {
                      _onSend();
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
