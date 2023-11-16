/* Screen of the event page with join/leave, chat and event's info */
// inb4 this might just be a stateless widget

import 'package:biketogether/modules/bikeEvent.dart';
import 'package:biketogether/modules/bikePath.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
      return FutureBuilder(
        future: FirebaseDatabase.instance
            .ref()
            .child('eventi_creati/$eventName')
            .once(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final event = BikeEvent.fromDB(Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map));
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Row(
                  children: [
                    Text(event.name),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Text('${event.creator} create at ${event.createAt}'),
                  FutureBuilder(
                      future: FirebaseDatabase.instance
                          .ref()
                          .child('percorsi/${event.bikeRouteName}')
                          .once(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final bikepathinfo = BikePath.fromDB(
                              Map<String, dynamic>.from(
                                  snapshot.data!.snapshot.value as Map));
                          return Text(
                              '${bikepathinfo.name} | ${bikepathinfo.type} | ${bikepathinfo.url} ');
                        }
                        return const CircularProgressIndicator();
                      })
                ],
              ),
            );
          } else {
            return const Text('No data about the event');
          }
        },
      );

  }
}
