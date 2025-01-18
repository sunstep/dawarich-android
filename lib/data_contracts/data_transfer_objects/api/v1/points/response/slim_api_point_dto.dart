
class SlimApiPointDTO {

  String? latitude;
  String? longitude;
  int? timestamp;

  SlimApiPointDTO(Map<String, dynamic> point){
    latitude = point['latitude'];
    longitude = point['longitude'];
    timestamp = point['timestamp'];
  }
}