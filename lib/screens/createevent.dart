import 'package:biketogether/modules/bikePath.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<StatefulWidget> createState() => _createEventState();
}

class _createEventState extends State<CreateEvent> {
  String _selectedPath = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: FirebaseDatabase.instance.ref().child('percorsi').once(),
            builder: (context, snapshot) {
              final allSelections = <DropdownMenuItem>[];
              if (snapshot.hasData) {
                final allPaths = Map<String, dynamic>.from(
                    (snapshot.data!.snapshot.value as Map));
                allSelections.addAll(allPaths.values.map((e) {
                  final path = BikePath.fromDB(Map<String, dynamic>.from(e));
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
                    items: allSelections,
                    onChanged: (e) {
                      _selectedPath = e.toString();
                    });
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ],
      ),
    );
  }
}
