
class SlimApiPoint {

  String? latitude;
  String? longitude;
  int? timestamp;

  SlimApiPoint(Map<String, dynamic> point){
    latitude = point['latitude'];
    longitude = point['longitude'];
    timestamp = point['timestamp'];
  }
}