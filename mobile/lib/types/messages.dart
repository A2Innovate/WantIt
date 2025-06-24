final class Message {
  final int id;
  final String content;
  final DateTime createdAt;
  final int senderId;
  final bool edited;
  Message({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.senderId,
    required this.edited,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderId: json['sender_id'] as int,
      edited: json['edited'] as bool,
    );
  }
}

final class PersonClass {
  final int id;
  final String name;
  final String username;

  PersonClass({required this.id, required this.name, required this.username});
  factory PersonClass.fromJson(Map<String, dynamic> json) {
    return PersonClass(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
    );
  }
}

final class LastMessage {
  final DateTime createdAt;
  final String content;
  final PersonClass person;

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      createdAt: DateTime.parse(json['createdAt'] as String),
      content: json['content'] as String,
      person: PersonClass.fromJson(json['person'] as Map<String, dynamic>),
    );
  }

  LastMessage({
    required this.createdAt,
    required this.content,
    required this.person,
  });
}
