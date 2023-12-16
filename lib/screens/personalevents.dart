import 'package:biketogether/modules/bike_event.dart';
import 'package:biketogether/screens/event.dart';
import 'package:biketogether/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('I Miei Eventi'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.lock_open_outlined),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('Codice Evento'),
                      content: TextField(
                        onSubmitted: (value) {
                          FirebaseDatabase.instance
                              .ref()
                              .child('events')
                              .orderByChild('passcode')
                              .equalTo(value)
                              .get()
                              .then((value) {
                                print(value);
                            if (!value.exists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        'Codice invalido')),
                              );
                            } else {
                              FirebaseDatabase.instance
                                  .ref(
                                      'events/${value.children.first.key}/partecipants')
                                  .update({
                                FirebaseAuth.instance.currentUser!.uid:
                                    DateTime.now().millisecondsSinceEpoch
                              });
                              Navigator.of(context).pop();
                            }
                          });
                        },
                      ),
                    ));
          },
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              builder: (context, snapshot) {
                final cardList = <Card>[];
                if (snapshot.hasData) {
                  if (!snapshot.data!.snapshot.exists) {
                    return const Text('Nessun evento è ancora stato creato');
                  }
                  final allEvents = Map<String, dynamic>.from(
                      snapshot.data!.snapshot.value as Map);
                  cardList.addAll(allEvents.entries
                      .where((element) => (element.value['partecipants'] ??
                              {} as Map)
                          .containsKey(FirebaseAuth.instance.currentUser!.uid))
                      .map((e) {
                    final event =
                        BikeEvent.fromDB(Map<String, dynamic>.from(e.value));
                    return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        margin: const EdgeInsets.all(8),
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Badge(
                                isLabelVisible: event.private,
                                largeSize:24,
                                alignment: Alignment.bottomRight,
                                backgroundColor: Colors.grey.withOpacity(0.3),
                                offset: Offset(10,13),
                                label:Icon(Icons.lock_outline),
                                  child: Icon(Icons.pedal_bike)),
                              title: Text(event.name),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EventPage(
                                            eventname: e.key.toString())));
                              },
                              subtitle: Text(
                                  'Created by ${event.creatorName} | Date ${event.date.toString().substring(0, 10)}'),
                            )
                          ],
                        ));
                  }));
                  if (cardList.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Text('Nessun evento a cui partecipti'),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MyHomePage(title: 'Biketogether')));
                              },
                              child: Text('Homepage'))
                        ],
                      ),
                    );
                  }
                  return Expanded(
                      child: ListView(
                    children: cardList,
                  ));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          "Error while fetching events\n ${snapshot.error}"));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
              stream: // TODO vengono fetchati in modo ordinato ma non mappati nello stesso ordine, maybe utilize onChild...
                  FirebaseDatabase.instance.ref().child('events').onValue,
            ),
          ],
        ));
  }
}
