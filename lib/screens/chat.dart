/* Screen of the chat page*/
//TODO to implement
import 'package:biketogether/modules/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class chatMessageUtil extends StatelessWidget {
  const chatMessageUtil({Key? key, required this.msg, required this.isAuthor})
      : super(key: key);
  final ChatMessage msg;
  final bool isAuthor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(isAuthor ? 64 : 16, 4, isAuthor ? 16 : 64, 4),
      child: Row(
        children: [
          !isAuthor
              ? CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blueGrey,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(msg.urlSenderAvatar),
                  ))
              : Container(),
          Expanded(
            child: Align(
              alignment:
                  isAuthor ? Alignment.centerRight : Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: isAuthor
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      !isAuthor
                          ? Text(
                              msg.creatorName,
                              overflow: TextOverflow.fade,
                            )
                          : Container(),
                      Text(msg.text),
                      Text(
                          '${msg.timestamp.day}/${msg.timestamp.month}  ${msg.timestamp.hour}:${msg.timestamp.minute}')
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream:
                  FirebaseDatabase.instance.ref('events/$eventId/chat').onValue,
              builder: (context, snapshot) {
                final messageList = <chatMessageUtil>[];
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final messages = Map<String, dynamic>.from(
                      snapshot.data!.snapshot.value as Map);
                  final sortedMessages = <ChatMessage>[];
                  sortedMessages.addAll(messages.entries.map((e) {
                    return ChatMessage.fromDB(
                        Map<String, dynamic>.from(e.value));
                  }));
                  sortedMessages.sort((a, b) {
                    return a.timestamp.millisecondsSinceEpoch >=
                            b.timestamp.millisecondsSinceEpoch
                        ? 0
                        : 1;
                  });
                  messageList.addAll(sortedMessages.map((message) {
                    return chatMessageUtil(
                        msg: message,
                        isAuthor: FirebaseAuth.instance.currentUser!.uid ==
                            message.creatorUid);
                  }));
                }
                return Expanded(
                    child: ListView(
                  reverse: true,
                  children: messageList,
                ));
              }),
        ],
      ),
    );
  }
}
