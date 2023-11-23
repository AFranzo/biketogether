import 'package:biketogether/modules/bikeEvent.dart';
import 'package:biketogether/modules/bikePath.dart';
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
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = "";
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
        formFields.update('date', (value) => _picked.millisecondsSinceEpoch,
            ifAbsent: () => _picked.millisecondsSinceEpoch);
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
          child: Column(
            children: [
              const Text('Seleziona il tipo di percosro'),
              FutureBuilder(
                future:
                    FirebaseDatabase.instance.ref().child('percorsi').once(),
                builder: (context, snapshot) {
                  final allSelections = <DropdownMenuItem>[];
                  if (snapshot.hasData) {
                    final allPaths = Map<String, dynamic>.from(
                        (snapshot.data!.snapshot.value as Map));
                    allSelections.addAll(allPaths.values.map((e) {
                      final path =
                          BikePath.fromDB(Map<String, dynamic>.from(e));
                      return DropdownMenuItem(
                        value: path.name,
                        child: Row(
                          children: [
                            Icon(
                                path.type == 'roadbike' //TODO find better icons
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
                            // TODO change creator to user
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
                                .toString(), partecipants: [])); // TODO da defaultare con username
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                  'Evento Creato')), // TODO check if event is created maybe and report success
                        );
                      }
                    },
                    child: const Text('Submit'), // TODO switch to homepage after submit
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
