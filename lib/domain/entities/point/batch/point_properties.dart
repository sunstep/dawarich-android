
abstract class PointProperties {

  String get timestamp;
  double get horizontalAccuracy;
  double get verticalAccuracy;
  double get altitude;
  double get speed;
  double get speedAccuracy;
  double get course;
  double get courseAccuracy;
  String get trackId;
  String get deviceId;

  // Convert the properties to a JSON-like map.
  Map<String, dynamic> toJson();
}