/*
* Class that represent a bike path
* */
class BikeRoute {
  final String advice;
  final String area;
  final String description;
  final String difficulty;
  final double duration;
  final int lenght;
  final Uri link;
  final String name;
  final String pointArrival;
  final String pointStart;
  final String synthesis;
  final String type;

  BikeRoute(
      this.advice,
      this.area,
      this.description,
      this.difficulty,
      this.duration,
      this.lenght,
      this.link,
      this.name,
      this.pointArrival,
      this.pointStart,
      this.synthesis,
      this.type);

  factory BikeRoute.fromDB(Map<String, dynamic> data) {
    return BikeRoute(
        data['advice'],
        data['area'],
        data['description'],
        data['difficulty'],
        data['duration'],
        data['lenght'],
        Uri(path: data['link']),
        data['name'],
        data['pointArrival'],
        data['pointStart'],
        data['synthesis'],
        data['type']);
  }
}
