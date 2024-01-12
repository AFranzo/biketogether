/*
* Class that represent a bike path
* */
import 'dart:ffi';

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
      {required this.advice,
      required this.area,
      required this.description,
      required this.difficulty,
      required this.duration,
      required this.lenght,
      required this.link,
      required this.name,
      required this.pointArrival,
      required this.pointStart,
      required this.synthesis,
      required this.type});

  factory BikeRoute.fromDB(Map<String, dynamic> data) {
    return BikeRoute(
        advice:data['advice'],
        area:data['area'],
        description:data['description'],
        difficulty:data['difficulty'],
        duration:   double.parse(data['duration'].toString()),
        lenght: int.parse(data['lenght'].toString()),
        link:Uri.parse(data['link']),
        name: data['name'],
        pointArrival:data['pointArrival'],
        pointStart:data['pointStart'],
        synthesis:data['synthesis'],
        type:data['type']);
  }
}
