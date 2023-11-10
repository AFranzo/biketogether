import 'package:biketogether/modules/bikeEvent.dart';
import 'package:biketogether/modules/bikePath.dart';
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
  @override
  void initState() {
    super.initState();
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
                            Icon(path.type == 'roadbike'
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
                      validator:  (value) => value == null ? 'Seleziona un percorso' : null,
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
                },
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Nome dell\'evento'),
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    formFields.update(
                        'date', (value) => newDateTime.millisecondsSinceEpoch,
                        ifAbsent: () => newDateTime.millisecondsSinceEpoch);
                  },
                  use24hFormat: true,
                  minuteInterval: 1,
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
                            creator: 'Franz',// TODO change creator to user
                            date: DateTime.fromMillisecondsSinceEpoch(
                                formFields['date']??DateTime.now().millisecondsSinceEpoch ) ,
                            bikeRouteName: formFields['bikepath'],
                            createAt: DateTime.now(),
                            name: formFields['event_name']==''?'Evento di':formFields['event_name'] ?? 'Evento di' )); // TODO da defaultare con username
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                  'Evento Creato')), // TODO check if event is created maybe and report success
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
