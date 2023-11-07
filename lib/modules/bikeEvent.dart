import 'package:firebase_database/firebase_database.dart';

/*
* Class that represent a created Event
* */
class BikeEvent {
  final String
      creator; //TODO da cambiare con l'user token accessibile tramite firebase
  final DateTime date;
  final String bikeRouteName;
  final DateTime createAt;


  BikeEvent(
      {required this.creator,
      required this.date,
      required this.bikeRouteName,
      required this.createAt,
});

  /*
  * Insert a bike event
  * */
  static void insertEvent(BikeEvent b) {
    FirebaseDatabase.instance.ref('eventi_creati').push().set({

      'creator': b.creator,
      'createdAt': b.createAt.millisecondsSinceEpoch,
      'bikepath': b.bikeRouteName,
      'date': b.date.millisecondsSinceEpoch
    });
  }

  factory BikeEvent.fromDB(Map<String, dynamic> data) {
    return BikeEvent(
        creator: data['creator'] ?? 'creator',
        date: DateTime.fromMillisecondsSinceEpoch(data['date']),
        bikeRouteName: data['bikepath'] ?? 'bikepath',
        createAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']));
  }
}
