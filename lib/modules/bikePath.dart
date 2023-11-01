import 'package:firebase_database/firebase_database.dart';


/*
* Class that represent a bike path
* */
class BikePath {
  final String name;
  final Uri url;

  BikePath(this.name, this.url);

/*
* Method to fetch all the bike paths from the database
* Returns a List of Bikepaths
* */
  static Future<List<BikePath>> getAllBikePaths() async {
    List<BikePath> ret = [];

    FirebaseDatabase.instance.ref('percorsi').onValue.listen((event) {
      for (var ev in event.snapshot.children) {
        print(ev.child('name').value.toString());
        ret.add(BikePath(ev.child('name').value.toString(),
            Uri(path: ev.child('link').value.toString())));
      }
    });
    return ret;
  }

/*
* Method that retrieve a bikepath given its name, might be useful
* Returns a Future promise or null
* */
  static Future<BikePath>? getBikePathInfo(String name) {
    return FirebaseDatabase.instance
        .ref('percorsi')
        .child(name)
        .get()
        .then((value) => BikePath(value.child('name').value.toString(), Uri()));
  }
}
