import 'package:biketogether/modules/bike_event.dart';
import 'package:biketogether/modules/bike_route.dart';
import 'package:biketogether/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<StatefulWidget> createState() => _createEventState();
}

class _createEventState extends State<CreateEvent> {
  String _selectedPath = '';
  final _form = GlobalKey<FormState>();
  Map<String, dynamic> formFields = {};
  late DateTime first;
  ///Date controller
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeC = TextEditingController();
  @override
  void initState() {
    super.initState();
    _dateController.text = "";
  }

  ///Time
  TimeOfDay timeOfDay = TimeOfDay.now();

  Future displayTimePicker(BuildContext context) async{
    var time = await showTimePicker(context: context, initialTime: timeOfDay);

    if(time != null){
      setState(() {
        _timeC.text = "${time.hour}:${time.minute}";
        DateTime finalDate = DateTime(first.year, first.month, first.day, time.hour, time.minute);
        formFields.update('date', (value) => finalDate.millisecondsSinceEpoch,
            ifAbsent: () => finalDate.millisecondsSinceEpoch);
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (_picked != null) {
      setState(() {
        _dateController.text = _picked.toString().split(" ")[0];
        first = DateTime(_picked.year, _picked.month, _picked.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Event'),
      ),
      body: Form(
        key: _form,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            // wrapped by ScrollView to avoid overflow when keyboard overlaps buttons
            child: Column(
              children: [
                const Text('Seleziona il tipo di percosro'),
                FutureBuilder(
                  future:
                      FirebaseDatabase.instance.ref().child('routes').once(),
                  builder: (context, snapshot) {
                    final allSelections = <DropdownMenuItem>[];
                    if (snapshot.hasData) {
                      final allPaths = Map<String, dynamic>.from(
                          (snapshot.data!.snapshot.value as Map));
                      allSelections.addAll(allPaths.values.map((e) {
                        final path =
                            BikeRoute.fromDB(Map<String, dynamic>.from(e));
                        return DropdownMenuItem(
                          value: path.name,
                          child: Row(
                            children: [
                              Icon(path.type ==
                                      'roadbike' //TODO find better icons
                                  ? Icons.electric_bike
                                  : Icons.pedal_bike),
                              const SizedBox(
                                width: 10,
                              ), // lul just for padding
                              Text(path.name),
                            ],
                          ),
                        );
                      }));
                      return DropdownButtonFormField(
                          validator: (value) =>
                              value == null ? 'Seleziona un percorso' : null,
                          items: allSelections,
                          onChanged: (e) {
                            _selectedPath = e.toString();
                            formFields.update(
                                'bikepath', (value) => _selectedPath,
                                ifAbsent: () => _selectedPath);
                          });
                    } else {
                      return const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                          ],
                        ),
                      );
                    }
                  },
                ),
                TextFormField(
                  validator: (value) {
                    formFields.update('event_name', (e) => value,
                        ifAbsent: () => value);
                    return null;
                  },
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Nome dell\'evento'),
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  validator: (value) {
                    formFields.update('desc', (e) => value,
                        ifAbsent: () => value);
                    return null;
                  },
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(), labelText: 'Descrizione'),
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Data Evento',
                        filled: true,
                        prefixIcon: Icon(Icons.calendar_today),
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate();
                      },
                    ),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: TextField(
                      controller: _timeC,
                      decoration: const InputDecoration(
                        labelText: 'Orario Evento',
                        filled: true,
                        prefixIcon: Icon(Icons.alarm), //TODO find better icons
                        enabledBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      readOnly: true,
                      onTap: (){
                        if(_dateController.text.isEmpty){
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Errore'),
                                content: const SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text('Inserisci prima la data.'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Ok'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }else {
                          displayTimePicker(context);
                        }
                      }
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_form.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database
                          BikeEvent.insertEvent(BikeEvent(
                              creatorId: FirebaseAuth.instance.currentUser!.uid,
                              date: DateTime.fromMillisecondsSinceEpoch(
                                  formFields['date'] ??
                                      DateTime.now().millisecondsSinceEpoch),
                              bikeRouteName: formFields['bikepath'],
                              createAt: DateTime.now(),
                              name: formFields['event_name'] == ''
                                  ? 'Evento di ${FirebaseAuth.instance.currentUser!.displayName.toString()}'
                                  : formFields['event_name'] ??
                                      'Evento di ${FirebaseAuth.instance.currentUser!.displayName.toString()}',
                              creatorName: FirebaseAuth
                                  .instance.currentUser!.displayName
                                  .toString(),
                              partecipants: [],
                              description: formFields['desc'] ?? ''));

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                    'Evento Creato')), // TODO check if event is created maybe and report success
                          );
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(title: 'Biketogether')) );
                        }
                      },
                      child: const Text(
                          'Submit'), // TODO switch to homepage after submit
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
