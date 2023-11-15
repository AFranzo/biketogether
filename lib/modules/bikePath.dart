
/*
* Class that represent a bike path
* */
class BikePath {
  final String name;
  final String type;
  final Uri url; // TODO da vedere come gestire gli eventuali link

  BikePath(this.name, this.url, this.type);

  factory BikePath.fromDB(Map<String, dynamic> data) {
    return BikePath(data['name'], Uri(path: data['lnk']), data['type']);
  }
}
