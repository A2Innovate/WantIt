final class Message {
  final int id;
  String content;
  final DateTime createdAt;
  final int senderId;
  bool edited;
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
      createdAt: DateTime.parse(json['createdAt'] as String),
      senderId: json['senderId'] as int,
      edited: json['edited'] as bool,
    );
  }
  void applyPartialUpdate(Map<String, dynamic> json) {
    if (json.containsKey('content')) {
      content = json['content'] as String;
      edited = true;
    }
    edited = true;
  }
}

final class Person {
  final int id;
  final String name;
  final String username;

  Person({required this.id, required this.name, required this.username});
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
    );
  }
}

final class LastMessage {
  final DateTime createdAt;
  final String content;
  final Person person;

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      createdAt: DateTime.parse(json['createdAt'] as String),
      content: json['content'] as String,
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
    );
  }

  LastMessage({
    required this.createdAt,
    required this.content,
    required this.person,
  });
}
