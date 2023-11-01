import 'package:firebase_database/firebase_database.dart';
/*
* Class that represent a created Event
* */
class BikeEvent {
   String creator; //TODO da cambiare con l'user token accessibile tramite firebase
   DateTime date;
   String bikeRouteName;
   DateTime createAt;
   BikeEvent(
      {required this.creator, required this.date , required this.bikeRouteName, required this.createAt});
  /*
  * Insert a bikeEvent into the database
  *
  * */
  static void insertEvent(BikeEvent b) {
    FirebaseDatabase.instance.ref('eventi_creati').push().set(
        {'creator': b.creator, 'createdAt': b.createAt.millisecondsSinceEpoch,'bikepath':b.bikeRouteName,'date':b.date.millisecondsSinceEpoch});
  }
  /*
  * Method to fetch all bikeEvents from database
  * It returns a list of bikeEvents 
  * */
  static Future<List<BikeEvent>> getAllBikeEvents() async {
    List<BikeEvent> ret = [];
    FirebaseDatabase.instance.ref('eventi_creati').onValue.listen((event) {
      for (var ev in event.snapshot.children){
        ret.add(BikeEvent(creator: ev.child('creator').value.toString(), date: DateTime.fromMillisecondsSinceEpoch(ev.child('date').value as int),createAt:  DateTime.fromMillisecondsSinceEpoch(ev.child('createdAt').value as int), bikeRouteName: ev.child('bikepath').value.toString()));
      }
    });

    return ret;
  }
}