import 'package:mobile/types/messages.dart';

import 'client.dart';

List<LastMessage> _lastMessages = [];

Future<List<LastMessage>> fetchLastMessages() async {
  final response = await useApi().get('/chat');
  _lastMessages = (response.data as List)
      .map((e) => LastMessage.fromJson(e as Map<String, dynamic>))
      .toList();
  return _lastMessages;
}

void upsertLastMessage(
  int personId,
  String senderName,
  String senderUsername,
  DateTime createdAt,
  String content,
) {
  final index = _lastMessages.indexWhere((msg) => msg.person.id == personId);
  if (index == -1) {
    _lastMessages.add(
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
    _lastMessages[index] = LastMessage(
      createdAt: createdAt,
      content: content,
      person: Person(id: personId, name: senderName, username: senderUsername),
    );
  }
}
