import 'package:firebase_auth/firebase_auth.dart';
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
  final String? description;
  final String? passcode;
  bool private;
  final List<String> partecipants;

  BikeEvent(
      {required this.creatorName,
      required this.creatorId,
      required this.date,
      required this.bikeRouteName,
      required this.createAt,
      required this.name,
      required this.description,
      required this.private,
      this.passcode,
      required this.partecipants});


  /*
  * Insert a bike event
  * */
  static void insertEvent(BikeEvent b) {
    FirebaseDatabase.instance.ref('events').push().set({
      'creatorName': b.creatorName,
      'private': b.private,
      'creatorId': b.creatorId,
      'createdAt': b.createAt.millisecondsSinceEpoch,
      'route': b.bikeRouteName,
      'date': b.date.millisecondsSinceEpoch,
      'name': b.name,
      'description': b.description,
      'passcode': b.passcode,
      'partecipants':{
        FirebaseAuth.instance.currentUser!.uid:DateTime.now().millisecondsSinceEpoch
      }
    });
  }

  factory BikeEvent.fromDB(Map<String, dynamic> data) {
    List<String> parts = [];
    if (data['partecipants'] != null) {
      Map partMap = data['partecipants'] as Map;
      partMap.forEach((key, value) {
          parts.add(key);
      });
    }
    return BikeEvent(
        creatorName: data['creatorName'] ?? 'creator',
        creatorId: data['creatorId'] ?? 'creatorId',
        date: DateTime.fromMillisecondsSinceEpoch(data['date']),
        bikeRouteName: data['route'] ?? 'route',
        createAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
        name: data['name'] ?? 'name',
        partecipants: parts,
        description: data['description'] ?? '', private: data['private']??false, passcode: data['passcode']);

  }
}
