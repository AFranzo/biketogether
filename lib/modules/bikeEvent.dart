import 'package:firebase_database/firebase_database.dart';

/*
* Class that represent a created Event
* */
class BikeEvent {
  final String creatorName;
  final String creatorId;
  final DateTime date;
  final String bikeRouteName;
  final DateTime createAt;
  final String name;
  final List<String> partecipants;

  BikeEvent(
      {required this.creatorName,
      required this.creatorId,
      required this.date,
      required this.bikeRouteName,
      required this.createAt,
      required this.name,
      required this.partecipants});

  /*
  * Insert a bike event
  * */
  static void insertEvent(BikeEvent b) {
    FirebaseDatabase.instance.ref('eventi_creati').push().set({
      'creatorName': b.creatorName,
      'creatorId': b.creatorId,
      'createdAt': b.createAt.millisecondsSinceEpoch,
      'bikepath': b.bikeRouteName,
      'date': b.date.millisecondsSinceEpoch,
      'name': b.name
    });
  }

  factory BikeEvent.fromDB(Map<String, dynamic> data) {

    List<String> parts = [];
    if ( data['partecipants'] != null) {
      Map part_map = data['partecipants'] as Map;
      part_map.forEach((key, value) {
        Map part = value as Map;
        part.forEach((key, value) { parts.add(value);});
      });
    }
    return BikeEvent(
        creatorName: data['creatorName'] ?? 'creator',
        creatorId: data['creatorId'] ?? 'creatorId',
        date: DateTime.fromMillisecondsSinceEpoch(data['date']),
        bikeRouteName: data['bikepath'] ?? 'bikepath',
        createAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
        name: data['name'] ?? 'event name', partecipants: parts );
  }
}
