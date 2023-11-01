/* homepage con searchbar e lista eventi */
import 'package:biketogether/modules/bikeEvent.dart';
import 'package:biketogether/screens/createevent.dart';
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
  late Future<List<BikeEvent>> allevents;

  //late Future<List<bikeEvent>> joinedevents;

  @override
  void initState() {
    allevents = BikeEvent.getAllBikeEvents();
  }

  Future<void> _refreshEvents() async {
    List<BikeEvent> newevents = await BikeEvent.getAllBikeEvents();
      setState(() {
      allevents = Future.value(newevents);
    });
  }

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
      body: RefreshIndicator(
        onRefresh: _refreshEvents,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Public events'),
            Expanded(
              child: FutureBuilder<List<BikeEvent>>(
                future: allevents,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
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
                                    title: const Text('name'), //TODO to change to some name per event, TBD
                                    subtitle: Text(
                                        'Created by ${snapshot.data!.elementAt(index).creator.toString()} | Date ${snapshot.data!.elementAt(index).date.toString().substring(0,10)}'),
                                  )
                                ],
                              ));
                        });
                  } else if (snapshot.hasError) {
                    return Text("Error while fetching events\n ${snapshot.error}");
                  } else {
                    return const Text('No Public Events');
                  }
                },
              ),
            )
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Create Event'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateEvent()));
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                BikeEvent.insertEvent(BikeEvent(creator: 'Franz', date: DateTime.parse('2023-10-20'), bikeRouteName: 'aaaaad',createAt: DateTime.now()));
                //TODO firebase logout
              },
            )
          ],
        ),
      ),
    );
  }
}
