import 'package:firebase_database/firebase_database.dart';

class ChatMessage {
  String text;
  String creatorName;
  String creatorUid;
  DateTime timestamp;
  String urlSenderAvatar;

  ChatMessage(
      {required this.text,
      required this.creatorName,
      required this.creatorUid,
      required this.timestamp,
      required this.urlSenderAvatar});

  factory ChatMessage.fromDB(Map<String, dynamic> data) {
    return ChatMessage(
        text: data['text'],
        creatorName: data['creatorName'],
        creatorUid: data['creatorUid'],
        timestamp: DateTime.now(),
        urlSenderAvatar: data['urlSenderAvatar']);
  }

  static void sendMessage(ChatMessage msg, eventId) {
    FirebaseDatabase.instance.ref('events/$eventId/chat').push().set({
      'text': msg.text,
      'creatorUid': msg.creatorUid,
      'creatorName': msg.creatorName,
      'timestamp': msg.timestamp,
      'urlSenderAvatar': msg.urlSenderAvatar
    });
  }
}
