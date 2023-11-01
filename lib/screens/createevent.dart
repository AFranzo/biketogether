import 'package:biketogether/modules/bikePath.dart';
import 'package:flutter/material.dart';

class CreateEvent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _createEventState();
}

class _createEventState extends State<CreateEvent> {
  late Future<List<BikePath>> bikepaths;

  String _selectedPath='';

  @override
  void initState() {
    super.initState();
    bikepaths = Future.value(BikePath.getAllBikePaths());
  }

  @override
  Widget build(BuildContext context) {
//TODO race condition, la lista viene fetchata dopo che il dropdown sia costruito
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<BikePath>>(
            future: bikepaths,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DropdownButtonFormField(
                  value: _selectedPath,
                  items: snapshot.data
                      ?.map((e) => DropdownMenuItem(
                            value: e.name,
                            child: Text(e.name),
                          ))
                      .toList(),
                  onChanged: (e) => {
                    print('changing'+e!),
                    setState(() {
                      _selectedPath = e;
                    })
                  },
                );
              } else {
                return const Text("Cannot retrieve events");
              }
            },
          )
        ],
      ),
    );
  }
}
