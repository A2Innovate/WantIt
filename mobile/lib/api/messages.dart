import 'package:mobile/types/messages.dart';

import 'client.dart';

List<LastMessage> lastMessages = [];

Future<List<LastMessage>> getLastMessages() async {
  final response = await useApi().get('/chat');
  lastMessages = (response.data as List)
      .map((e) => LastMessage.fromJson(e as Map<String, dynamic>))
      .toList();
  return lastMessages;
}
