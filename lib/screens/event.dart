/* Screen of the event page with join/leave, chat and event's info */
// inb4 this might just be a stateless widget

import 'package:biketogether/modules/bikeEvent.dart';
import 'package:biketogether/modules/bikePath.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key, required this.eventname});

  final String eventname;

  @override
  State<StatefulWidget> createState() => _EventPageState(eventName: eventname);
}

class _EventPageState extends State<EventPage> {
  final String eventName;

  _EventPageState({required this.eventName});

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
      ),
      body: FutureBuilder(
        future: FirebaseDatabase.instance
            .ref()
            .child('eventi_creati/$eventName')
            .once(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final event = BikeEvent.fromDB(Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map));
            return Text('${event.creator} create at ${event.createAt}');
          } else {
            return const Text('No data about the event');
          }
        },
      ),
    );
  }
}
