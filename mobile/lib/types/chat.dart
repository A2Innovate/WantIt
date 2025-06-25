import 'package:mobile/types/messages.dart';

final class Chat {
  final Person person;
  final List<Message> messages;

  Chat.fromJson(Map<String, dynamic> json)
    : person = Person.fromJson(json['person']),
      messages = (json['messages'] as List)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();

  Chat({required this.person, required this.messages});
}
