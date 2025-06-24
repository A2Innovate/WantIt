import 'package:flutter/material.dart';
import 'package:mobile/types/messages.dart';
import 'package:mobile/api/messages.dart';

class MessagesProvider extends ChangeNotifier {
  List<LastMessage> lastMessages = [];

  Future<void> loadMessages() async {
    lastMessages = await getLastMessages();
    notifyListeners(); // Notifies all listening widgets
  }
}
