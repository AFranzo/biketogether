/* Screen of the event page with join/leave, chat and event's info */
// inb4 this might just be a stateless widget

import 'package:biketogether/modules/bikeEvent.dart';
import 'package:biketogether/modules/bikePath.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key, required this.eventname});

  final String eventname;

  @override
  State<StatefulWidget> createState() => _EventPageState(eventID: eventname);
}

class _EventPageState extends State<EventPage> {
  final String eventID;
  final _form = GlobalKey<FormState>();
  Map<String, dynamic> formFields = {};

  _EventPageState({required this.eventID});

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref()
            .child('eventi_creati/$eventID')
            .onValue,
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
                    const Spacer(),
                    (!event.partecipants
                            .contains(FirebaseAuth.instance.currentUser!.uid))
                        ? IconButton(
                            onPressed: () {
                              FirebaseDatabase.instance
                                  .ref('/eventi_creati/$eventID/')
                                  .child('partecipants')
                                  .push()
                                  .set({
                                'uid': FirebaseAuth.instance.currentUser!.uid
                              });
                            },
                            icon: const Icon(Icons.add))
                        : IconButton(
                            onPressed: () {
                              FirebaseDatabase.instance
                                  .ref('/eventi_creati/$eventID/partecipants/')
                                  .orderByChild('uid')
                                  .equalTo(
                                      FirebaseAuth.instance.currentUser!.uid)
                                  .ref
                                  .remove();
                            },
                            icon: const  Icon(Icons.remove)),
                    (event.creatorId == FirebaseAuth.instance.currentUser!.uid)
                        ? IconButton(
                        onPressed: () => {
                          showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Modifica Evento'),
                                  content: Form(
                                    key: _form,
                                    child: TextFormField(
                                        decoration: const InputDecoration(
                                            border:
                                            UnderlineInputBorder(),
                                            labelText:
                                            'Nome dell\'evento'),
                                        initialValue: event.name,
                                        validator: (value) {
                                          if (value == null ||
                                              value == '') {
                                            return "Nome non può essere nullo";
                                          }
                                          formFields.update(
                                              'event_name',
                                                  (e) => value,
                                              ifAbsent: () => value);
                                        }),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () => {
                                          if (_form.currentState!
                                              .validate())
                                            {
                                              FirebaseDatabase
                                                  .instance
                                                  .ref(
                                                  '/eventi_creati/$eventID/')
                                                  .update({
                                                'name': formFields[
                                                'event_name']
                                              }),
                                              Navigator.of(context)
                                                  .pop()
                                            }
                                        },
                                        child: const Text('Salva'))
                                  ],
                                );
                              })
                        },
                        icon: const Icon(Icons.settings))
                        : Container()
                  ],
                ),
              ),
              body: Column(
                children: [
                  Text('${event.creatorName} create at ${event.createAt}'),
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
            return Scaffold(
              appBar: AppBar(
                title: const Text('Loading'),
              ),
              body: const Center(
                child:  Column(
                  children: [CircularProgressIndicator()],
                ),
              ),
            );
          }
        });
  }
}
