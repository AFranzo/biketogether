/* Screen of the chat page*/
//TODO to implement
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.eventId});

  final String eventId;
  @override
  State<ChatPage> createState() => _ChatPageState(eventId: this.eventId);
}

class _ChatPageState extends State<ChatPage> {
  String eventId;
  _ChatPageState({required this.eventId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Chat'),
      ),
    );
  }
}
