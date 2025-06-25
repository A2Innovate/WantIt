import 'package:flutter/material.dart';
import 'package:mobile/types/messages.dart';
import 'package:mobile/api/messages.dart' as messageApi;

class MessagesProvider extends ChangeNotifier {
  List<LastMessage> messages = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchRefreshMessages() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      isLoading = true;
      messages = await messageApi.fetchLastMessages();
    } catch (e) {
      errorMessage = 'Failed to load messages: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
