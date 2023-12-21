/* Screen of the chat page*/
import 'package:biketogether/modules/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class chatMessageUtil extends StatelessWidget {
  const chatMessageUtil(
      {Key? key,
      required this.msg,
      required this.isAuthor,
      required this.isCreator})
      : super(key: key);
  final ChatMessage msg;
  final bool isAuthor;
  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.all(4),
      child: Row(
        children: [
          !isAuthor
              ? CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blueGrey,
                  child: Badge(
                    backgroundColor: Colors.amberAccent,
                    alignment: Alignment.bottomLeft,
                    offset: Offset(-10, 10),
                    isLabelVisible: isCreator,
                    largeSize: 22,
                    label: Text('Admin', style:TextStyle(
                      color: Colors.black
                    ),),
                    child: CircleAvatar(
                      radius: 23,
                      backgroundImage: NetworkImage(msg.urlSenderAvatar),
                    ),
                  ))
              : Spacer(),
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
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
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
  const ChatPage(
      {super.key, required this.eventId, required this.eventcreatorId});

  final String eventId;
  final String eventcreatorId;

  @override
  State<ChatPage> createState() => _ChatPageState(
      eventId: this.eventId, eventCreatorId: this.eventcreatorId);
}

class _ChatPageState extends State<ChatPage> {
  String eventId;
  String eventCreatorId;
  final textController = TextEditingController();

  _ChatPageState({required this.eventId, required this.eventCreatorId});

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
                          message.creatorUid,
                      isCreator: message.creatorUid == eventCreatorId,
                    );
                  }));
                }
                return Expanded(
                    child: ListView(
                  reverse: true,
                  children: messageList,
                ));
              }),
          SafeArea(
            bottom: true,
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black26))),
              child: TextField(
                onSubmitted: (msg) {
                  if (msg != '') {
                    ChatMessage.sendMessage(
                        ChatMessage(
                            text: msg,
                            creatorName: FirebaseAuth
                                    .instance.currentUser!.displayName ??
                                'sender',
                            creatorUid: FirebaseAuth.instance.currentUser!.uid,
                            timestamp: DateTime.now(),
                            urlSenderAvatar: FirebaseAuth
                                    .instance.currentUser!.photoURL ??
                                'https://www.pngrepo.com/png/182626/180/user-profile.png'),
                        eventId);
                  }
                  textController.clear();
                },
                controller: textController,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        textController.clear();
                      },
                    ),
                    contentPadding:
                        const EdgeInsets.only(right: 42, left: 16, top: 18),
                    hintText: 'messaggio'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
