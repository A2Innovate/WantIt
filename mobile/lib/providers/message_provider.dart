import 'package:flutter/material.dart';
import 'package:mobile/types/messages.dart';

import '../stores/client.dart';

class MessagesProvider extends ChangeNotifier {
  List<LastMessage> messages = [];
  bool isLoading = false;
  String? errorMessage;

  Future<List<LastMessage>> fetchLastMessages() async {
    final response = await useApi().get('/chat');
    return (response.data as List)
        .map((e) => LastMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> fetchRefreshMessages() async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();
    try {
      messages = await fetchLastMessages();
    } catch (e) {
      errorMessage = 'Failed to load messages: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void upsertLastMessage(
    int personId,
    String senderName,
    String senderUsername,
    DateTime createdAt,
    String content,
  ) {
    final index = messages.indexWhere((msg) => msg.person.id == personId);
    if (index == -1) {
      messages.add(
        LastMessage(
          createdAt: createdAt,
          content: content,
          person: Person(
            id: personId,
            name: senderName,
            username: senderUsername,
          ),
        ),
      );
    } else {
      messages[index] = LastMessage(
        createdAt: createdAt,
        content: content,
        person: Person(
          id: personId,
          name: senderName,
          username: senderUsername,
        ),
      );
      notifyListeners();
    }
  }
}
