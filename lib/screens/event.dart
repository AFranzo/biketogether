/* Screen of the event page with join/leave, chat and event's info */
// inb4 this might just be a stateless widget

import 'package:biketogether/modules/bike_event.dart';
import 'package:biketogether/modules/bike_route.dart';
import 'package:biketogether/screens/chat.dart';
import 'package:biketogether/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  _EventPageState({required this.eventID});

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            FirebaseDatabase.instance.ref().child('events/$eventID').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final event = BikeEvent.fromDB(Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map));
            _dateController.text=event.date.toString().substring(0,10);
            formFields['date']=event.date;
            _timeController.text='${event.date.hour}:${event.date.minute}';
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
                                      .update({
                                    FirebaseAuth.instance.currentUser!.uid:
                                        DateTime.now().millisecondsSinceEpoch
                                  });
                              },
                              icon: const Icon(Icons.add))
                          : Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>

                                                  ChatPage(eventId: eventID, eventcreatorId: event.creatorId,)));
                                    },
                                    icon: const Icon(Icons.chat)),
                                (event.creatorId !=
                                        FirebaseAuth.instance.currentUser!.uid)
                                    ? IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Abbandona evento'),
                                                  content: Text(
                                                      'vuoi abbandonare l\'evento "${event.name}"?'),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        FirebaseDatabase
                                                            .instance
                                                            .ref()
                                                            .child(
                                                                '/events/$eventID/partecipants/${FirebaseAuth.instance.currentUser!.uid}')
                                                            .remove();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                        'Lascia',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .redAccent)),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        icon: const Icon(Icons.remove))
                                    : PopupMenuButton(
                                        itemBuilder: (context) => [
                                              PopupMenuItem(
                                                child: const Text('Modifica'),
                                                onTap: () {
                                                  showDialog<void>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Modifica Evento'),
                                                          content: Form(
                                                            key: _form,
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                TextFormField(
                                                                    decoration: const InputDecoration(
                                                                        border:
                                                                            UnderlineInputBorder(),
                                                                        labelText:
                                                                            'Nome dell\'evento'),
                                                                    initialValue:
                                                                        event
                                                                            .name,
                                                                    validator:
                                                                        (value) {
                                                                      if (value ==
                                                                              null ||
                                                                          value ==
                                                                              '') {
                                                                        return "Nome non può essere nullo";
                                                                      }
                                                                      formFields.update(
                                                                          'event_name',
                                                                          (e) =>
                                                                              value,
                                                                          ifAbsent: () =>
                                                                              value);
                                                                    }),
                                                                TextFormField(
                                                                    decoration: const InputDecoration(
                                                                        border:
                                                                            UnderlineInputBorder(),
                                                                        labelText:
                                                                            'Descrizione dell\'evento'),
                                                                    initialValue:
                                                                        event
                                                                            .description,
                                                                    validator:
                                                                        (value) {
                                                                      formFields.update(
                                                                          'event_description',
                                                                          (e) =>
                                                                              value,
                                                                          ifAbsent: () =>
                                                                              value);
                                                                    }),
                                                                TextField(
                                                                  controller: _dateController,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    labelText:
                                                                        'Data Evento',
                                                                    filled:
                                                                        true,
                                                                    prefixIcon:
                                                                        Icon(Icons
                                                                            .calendar_today),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide.none),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.blue),
                                                                    ),
                                                                  ),
                                                                  readOnly:
                                                                      true,
                                                                  onTap: () async{
                                                                   var pickedDate = await showDatePicker(
                                                                        context:
                                                                            context,
                                                                        initialDate:
                                                                          event.date,
                                                                        firstDate:
                                                                            DateTime(
                                                                                2000),
                                                                        lastDate:
                                                                            DateTime(2101)

                                                                   );
                                                                   if (pickedDate != null){
                                                                     formFields.update('date', (value) => pickedDate, ifAbsent: ()=>pickedDate);
                                                                     _dateController.text=pickedDate.toString().substring(0,10);
                                                                   }
                                                                  },
                                                                ),
                                                                TextField(
                                                                  controller: _timeController,
                                                                  decoration:
                                                                      const InputDecoration(

                                                                    labelText:
                                                                        'Orario Evento',
                                                                    filled:
                                                                        true,
                                                                    prefixIcon:
                                                                        Icon(Icons
                                                                            .alarm),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide.none),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.blue),
                                                                    ),
                                                                  ),
                                                                  readOnly:
                                                                      true,
                                                                  onTap: () async{
                                                                    var pickedTime = await showTimePicker(
                                                                        context:
                                                                            context,
                                                                        initialTime:
                                                                            TimeOfDay.now()

                                                                    );
                                                                    if (pickedTime != null){
                                                                      formFields.update('date', (value) {
                                                                        value as DateTime;
                                                                        return DateTime(value.year,value.month,value.day,pickedTime.hour,pickedTime.minute);
                                                                      },);
                                                                      _timeController.text='${pickedTime.hour}:${pickedTime.minute}';
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                                onPressed:
                                                                    () => {
                                                                          if (_form
                                                                              .currentState!
                                                                              .validate())
                                                                            {

                                                                              FirebaseDatabase.instance.ref('/events/$eventID/').update({
                                                                                'name': formFields['event_name'],
                                                                                'description': formFields['event_description'],
                                                                                'date': (formFields['date'] as DateTime).millisecondsSinceEpoch
                                                                              }),
                                                                              Navigator.of(context).pop()
                                                                            }
                                                                        },
                                                                child:
                                                                    const Text(
                                                                        'Salva'))
                                                          ],
                                                        );
                                                      });
                                                },
                                              ),
                                              PopupMenuItem(
                                                child: const Text(
                                                  'Elimina',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Eliminazione evento'),
                                                          content: Text(
                                                              'vuoi eliminare l\'evento:\n${event.name}?'),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green,
                                                                      content: Text(
                                                                          'Evento eliminato')),
                                                                );
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const MyHomePage(title: 'Biketogether')));
                                                                FirebaseDatabase
                                                                    .instance
                                                                    .ref(
                                                                        'events/$eventID')
                                                                    .remove();
                                                              },
                                                              child: const Text(
                                                                  'Elimina',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                              style: ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all(
                                                                          Colors
                                                                              .redAccent)),
                                                            )
                                                          ],
                                                        );
                                                      });
                                                },
                                              ),

                                            ])
                              ],
                            )
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 26,
                              ),
                              Text(
                                ' ${event.date.toString().substring(0, 10)}',
                                style: const TextStyle(fontSize: 26),
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(right: 20.0)),
                              const Icon(
                                Icons.schedule,
                                size: 26,
                              ),
                              Text(
                                ' ${event.date.toString().substring(10, 16)}',
                                style: const TextStyle(fontSize: 26),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.group,
                                size: 26,
                              ),
                              Text(
                                ' ${event.partecipants.length}',
                                style: const TextStyle(fontSize: 26),
                              ),
                            ],
                          )
                        ],
                      ),
                      const Text('Descrizione evento:',
                          style: TextStyle(fontSize: 24)),
                      Text(event.description ?? 'No descrizione',
                          style: const TextStyle(fontSize: 18)),
                      // Text(
                      //   'creato da ${event.creatorName} il ${event.createAt.toString().substring(0, 10)}',
                      //   style: const TextStyle(fontSize: 20),
                      // ),
                      event.private?ElevatedButton(onPressed: (){
                        Clipboard.setData(ClipboardData(text: event.passcode??'Errore codice evento'));
                      }, child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Codice Evento: ${event.passcode}',textScaleFactor: 1.35,),
                          ),
                          Icon(Icons.copy)
                        ],
                      )):Container(),
                      const Padding(padding: EdgeInsets.only(bottom: 20.0)),
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
                                  child: ListView(children: [
                                // Container(
                                // color: Theme.of(context)
                                //     .appBarTheme
                                //     .shadowColor,
                                // child:
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.only(top: 20.0)),
                                    Text('Percorso: ${route.name}',
                                        style: const TextStyle(fontSize: 26)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        (route.difficulty == 'facile')
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.greenAccent,
                                                ),
                                                child: Row(children: [
                                                  const Icon(
                                                    Icons
                                                        .sentiment_satisfied_outlined,
                                                    size: 24,
                                                  ),
                                                  Text(' ${route.difficulty}',
                                                      style: const TextStyle(
                                                        fontSize: 24,
                                                      )),
                                                ]),
                                              )
                                            : (route.difficulty == 'media')
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color:
                                                          Colors.orangeAccent,
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
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.redAccent,
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
                                              Icons.hourglass_empty,
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
                                        padding: EdgeInsets.only(bottom: 20.0)),
                                    Text('Tipo: ${route.type}',
                                        style: const TextStyle(fontSize: 22)),
                                    Text('Zona: ${route.area}',
                                        style: const TextStyle(fontSize: 22)),
                                    Text('da: ${route.pointStart} ',
                                        style: const TextStyle(fontSize: 22)),
                                    Text('a: ${route.pointArrival}',
                                        style: const TextStyle(fontSize: 22)),
                                  ],
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 20.0)),
                                // ),
                                ExpansionTile(
                                  title: const Text('Consigli',
                                      style: TextStyle(fontSize: 22)),
                                  children: [
                                    ListTile(
                                        title: Text(route.advice,
                                            style:
                                                const TextStyle(fontSize: 16))),
                                  ],
                                ),
                                ExpansionTile(
                                  title: const Text('Descrizione',
                                      style: TextStyle(fontSize: 22)),
                                  children: [
                                    ListTile(
                                        title: Text(route.description,
                                            style:
                                                const TextStyle(fontSize: 16)))
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
