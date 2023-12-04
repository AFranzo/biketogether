/* Screen of the event page with join/leave, chat and event's info */
// inb4 this might just be a stateless widget

import 'package:biketogether/modules/bike_event.dart';
import 'package:biketogether/modules/bike_route.dart';
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
        stream:
            FirebaseDatabase.instance.ref().child('events/$eventID').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final event = BikeEvent.fromDB(Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map));
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: Row(
                    children: [
                      Expanded(
                          child: Text(
                        event.name,
                        overflow: TextOverflow.fade,
                      )),
                      (!event.partecipants
                              .contains(FirebaseAuth.instance.currentUser!.uid))
                          ? IconButton(
                              onPressed: () {
                                FirebaseDatabase.instance
                                    .ref('/events/$eventID/')
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
                                    .ref('/events/$eventID/partecipants/')
                                    .orderByChild('uid')
                                    .equalTo(
                                        FirebaseAuth.instance.currentUser!.uid)
                                    .ref
                                    .remove();
                              },
                              icon: const Icon(Icons.remove)),
                      (event.creatorId ==
                              FirebaseAuth.instance.currentUser!.uid)
                          ? PopupMenuButton(
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Text('Modifica'),
                                      onTap: () {
                                        showDialog<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Modifica Evento'),
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
                                                            ifAbsent: () =>
                                                                value);
                                                      }),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () => {
                                                            if (_form
                                                                .currentState!
                                                                .validate())
                                                              {
                                                                FirebaseDatabase
                                                                    .instance
                                                                    .ref(
                                                                        '/events/$eventID/')
                                                                    .update({
                                                                  'name': formFields[
                                                                      'event_name']
                                                                }),
                                                                Navigator.of(
                                                                        context)
                                                                    .pop()
                                                              }
                                                          },
                                                      child:
                                                          const Text('Salva'))
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                  ])
                          : Container(),
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.group,
                            size: 22,
                          ),
                          Text(
                            ' ${event.partecipants.length} partecipanti',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                      Text(
                        'creato da ${event.creatorName} il ${event.createAt.toString().substring(0, 10)}',
                        style: const TextStyle(fontSize: 22),
                      ),
                      Text(
                        'Data evento: ${event.date.toString().substring(0, 10)} alle ${event.date.toString().substring(10, 16)}',
                        style: const TextStyle(fontSize: 22),
                      ),
                      const Text('Descrizione evento:',
                          style: TextStyle(fontSize: 22)),
                      Text(event.description ?? 'Nessuna descrizione',
                          style: const TextStyle(fontSize: 16)),
                      const Divider(),
                      FutureBuilder(
                          future: FirebaseDatabase.instance
                              .ref()
                              .child('routes/${event.bikeRouteName}')
                              .once(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final route = BikeRoute.fromDB(
                                  Map<String, dynamic>.from(
                                      snapshot.data!.snapshot.value as Map));
                              return Expanded(
                                  child: ListView(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                    Container(
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .shadowColor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Text(
                                                'Percorso: ${route.name}',
                                                style: const TextStyle(
                                                    fontSize: 28)),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              (route.difficulty == 'facile')
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color:
                                                            Colors.greenAccent,
                                                      ),
                                                      child: Row(children: [
                                                        const Icon(
                                                          Icons
                                                              .sentiment_satisfied_outlined,
                                                          size: 24,
                                                        ),
                                                        Text(
                                                            ' ${route.difficulty}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 24,
                                                            )),
                                                      ]),
                                                    )
                                                  : (route.difficulty ==
                                                          'media')
                                                      ? Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors
                                                                .orangeAccent,
                                                          ),
                                                          child: Row(children: [
                                                            const Icon(
                                                              Icons
                                                                  .sentiment_neutral_outlined,
                                                              size: 24,
                                                            ),
                                                            Text(
                                                                ' ${route.difficulty}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 24,
                                                                )),
                                                          ]),
                                                        )
                                                      : Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors
                                                                .redAccent,
                                                          ),
                                                          child: Row(children: [
                                                            const Icon(
                                                              Icons
                                                                  .sentiment_very_dissatisfied_outlined,
                                                              size: 24,
                                                            ),
                                                            Text(
                                                                ' ${route.difficulty}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 24,
                                                                )),
                                                          ]),
                                                        ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.straighten,
                                                    size: 24,
                                                  ),
                                                  Text(' ${route.lenght} km',
                                                      style: const TextStyle(
                                                          fontSize: 24)),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.schedule,
                                                    size: 24,
                                                  ),
                                                  Text(' ${route.duration} h',
                                                      style: const TextStyle(
                                                          fontSize: 24)),
                                                ],
                                              )
                                            ],
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 10.0)),
                                          Text('Tipo: ${route.type}',
                                              style: const TextStyle(
                                                  fontSize: 24)),
                                          Text('Area: ${route.area}',
                                              style: const TextStyle(
                                                  fontSize: 24)),
                                          Text('Partenza: ${route.pointStart} ',
                                              style: const TextStyle(
                                                  fontSize: 22)),
                                          Text('Arrivo: ${route.pointArrival}',
                                              style:
                                                  const TextStyle(fontSize: 22))
                                        ],
                                      ),
                                    ),
                                    ExpansionTile(
                                      title: const Text('Consigli',
                                          style: TextStyle(fontSize: 22)),
                                      children: [
                                        ListTile(
                                            title: Text(route.advice,
                                                style: const TextStyle(
                                                    fontSize: 16))),
                                      ],
                                    ),
                                    ExpansionTile(
                                      title: const Text('Descrizione',
                                          style: TextStyle(fontSize: 22)),
                                      children: [
                                        ListTile(
                                            title: Text(route.description,
                                                style: const TextStyle(
                                                    fontSize: 16)))
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Row(
                                        children: [
                                          Text('Mappa percorso',
                                              style: TextStyle(fontSize: 22)),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10.0)),
                                          Icon(Icons.download)
                                        ],
                                      ),
                                    )
                                  ]));
                            }
                            return const CircularProgressIndicator();
                          })
                    ],
                  ),
                ));
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Loading'),
              ),
              body: const Center(
                child: Column(
                  children: [CircularProgressIndicator()],
                ),
              ),
            );
          }
        });
  }
}
