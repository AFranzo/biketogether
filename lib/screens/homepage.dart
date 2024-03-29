/* homepage con searchbar e lista eventi */
import 'package:biketogether/modules/bike_event.dart';
import 'package:biketogether/screens/createevent.dart';
import 'package:biketogether/screens/event.dart';
import 'package:biketogether/screens/personalevents.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login.dart';

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
  String searchedEventname = '';
  bool showOld = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
        title: const Text('Eventi pubblici'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.lock_open_outlined),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Codice Evento'),
                content: TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5)
                  ],
                  decoration: const InputDecoration(
                    hintText:'Inserisci il codice di 5 lettere'
                  ),
                  onSubmitted: (value) {
                    FirebaseDatabase.instance
                        .ref()
                        .child('events')
                        .orderByChild('passcode')
                        .equalTo(value)
                        .get()
                        .then((value) {
                      if (!value.exists) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                  'Codice invalido')),
                        );
                      } else {
                        try{
                        FirebaseDatabase.instance
                            .ref(
                            'events/${value.children.first.key}/partecipants')
                            .update({
                          FirebaseAuth.instance.currentUser!.uid:
                          DateTime.now().millisecondsSinceEpoch
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Partecipazione effettuata"),
                        ));

                        } catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text("Errore"),
                          ));
                        }
                        Navigator.of(context).pop();
                      }
                    });
                  },
                ),
              ));
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Eventi passati',
                  style: TextStyle(fontSize: 20),
                ),
                Switch(
                    splashRadius: 30.0,
                    value: showOld,
                    onChanged: (value) => setState(() => showOld = value)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.black45),
                    ),
                    labelText: 'Ricerca Evento',
                    suffixIcon: Icon(Icons.search)),
                onChanged: (e) {
                  searchedEventname = e;
                  setState(() {});
                }),
          ),
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
                    .where((element) =>
                        element.value['name']
                            .toString()
                            .toLowerCase()
                            .contains(searchedEventname.toLowerCase()) &&
                        (!DateTime.fromMillisecondsSinceEpoch(
                                    element.value['date'])
                                .isBefore(DateTime.now()) ||
                            showOld) &&
                        !(element.value['private'] as bool))
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
                            leading: const Icon(Icons.pedal_bike),
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
            stream:
                FirebaseDatabase.instance.ref().child('events').onValue,
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/logo64pxn.png",
                    height: 32,
                    width: 32,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                  ),
                  Text(widget.title),
                ],
              ),
              automaticallyImplyLeading: false,
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser!.photoURL??''),
                    ),
                    title: Text(FirebaseAuth.instance.currentUser!.displayName??'Username'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle),
                    title: const Text('Nuovo Evento'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateEvent()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.ballot),
                    title: const Text('I Miei Eventi'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyEventsPage()));
                    },
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(children : [ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Cancella i miei dati'),
                onTap: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Cancella i miei dati'),
                    content: const Text("Sei sicuro di voler cancellare i dati?\nL'operazione non sarà reversibile"),
                    actions: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.pink,
                        ),
                      onPressed: () =>
                        Navigator.pop(context, 'OK'),

              child: const Text('Indietro'),
            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                var currUser=FirebaseAuth.instance.currentUser?.uid;
                                var dbRef = FirebaseDatabase.instance.ref().child('events').get();
                                dbRef.then((value){
                                for(var e in value.children){
                                // removes events created by user
                                  if(e.child("creatorId").value ==currUser ){
                                    e.ref.remove();
                                  }else{ // removes from participants
                                    e.child("partecipants").children.forEach((element) {
                                    if(currUser == element.key) {
                                      element.ref.remove();
                                    }});
                                  }
                                  // removes messages sent by the user in all chats
                                  e.child("chat").children.forEach((msg) {
                                    if (msg.child('creatorUid').value == currUser){
                                      msg.ref.remove();
                                    }
                                  });

                                }}).then((value) async {
                                  FirebaseAuth.instance.currentUser?.reload();
                                  await Authentication.signOut(context: context);
                                  await FirebaseAuth.instance.currentUser?.delete();

                                }).then((value){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SignInPage()));
                                });

                              },
                              child: const Text('Confermo'),
                            )
                          ],),


                    ],
                  ),
                ),

              ),ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await Authentication.signOut(context: context).then((value){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInPage()));
                  });
                },
              ),
              ],
              ),
            )
          ],
        ),
      ),
    );



  }
}
