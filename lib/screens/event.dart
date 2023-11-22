/* Screen of the event page with join/leave, chat and event's info */
// inb4 this might just be a stateless widget

import 'package:biketogether/modules/bikeEvent.dart';
import 'package:biketogether/modules/bikePath.dart';
import 'package:biketogether/screens/map.dart';
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
          final event = BikeEvent.fromDB(
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map));
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Row(
                children: [
                  Text(event.name),
                ],
              ),
            ),
            body: FittedBox(
                fit: BoxFit.fitWidth,
                child: Column(
                  children: [
                    Text('creato da ${event.creatorName} il ${event.createAt}'),
                    Text('data evento: ${event.date}'),
                    Text('numero partecipanti: ?'),
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
                            return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('luogo: ${bikepathinfo.name}'),
                                  Text('tipo: ${bikepathinfo.type}'),
                                  Text(
                                      'informazioni aggiuntive: ${bikepathinfo.url}'),
                                ]);
                          }
                          return const CircularProgressIndicator();
                        }),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('CHAT'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OSMap()),
                        );
                      },
                      child: const Text('SEE ON MAP'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('JOIN'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('LEAVE'),
                    ),
                  ],
                )),
          );
        } else {
          return const Text('No data about the event');
        }
      },
    );
  }
}
