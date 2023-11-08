/* homepage con searchbar e lista eventi */
import 'package:biketogether/modules/bikeEvent.dart';
import 'package:biketogether/screens/createevent.dart';
import 'package:biketogether/screens/event.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Public events'),
          StreamBuilder(
            builder: (context, snapshot) {
              final cardList = <Card>[];
              if (snapshot.hasData) {
                final allEvents = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);
                cardList.addAll(allEvents.entries.map((e) {
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
                            leading: const Icon(Icons.pedal_bike),
                            title: Text(e.key.toString()),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EventPage(
                                          eventname: e.key.toString())));
                            },
                            subtitle: Text(
                                'Created by ${event.creator} | Date ${event.date.toString().substring(0, 10)}'),
                          )
                        ],
                      ));
                }));
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
                FirebaseDatabase.instance.ref().child('eventi_creati').onValue,
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_circle),
                    title: const Text('Create Event'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateEvent()));
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  // BikeEvent.insertEvent(BikeEvent(
                  //     creator: 'Franz',
                  //     date: DateTime.parse('2023-10-20'),
                  //     bikeRouteName: 'aaaaad',
                  //     createAt: DateTime.now()));
                  //TODO firebase logout
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
