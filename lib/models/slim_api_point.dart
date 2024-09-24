
import 'dart:ffi';

class SlimApiPoint {

  String? Latitude;
  String? Longitude;
  int? Timestamp;

  SlimApiPoint(Map<String, dynamic> point){
    Latitude = point['latitude'];
    Longitude = point['longitude'];
    Timestamp = point['timestamp'];
  }
}