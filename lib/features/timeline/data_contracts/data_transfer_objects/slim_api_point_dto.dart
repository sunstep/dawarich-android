
final class SlimApiPointDTO {

  int? timestamp;
  String? longitude;
  String? latitude;


  SlimApiPointDTO({
    required this.timestamp,
    required this.longitude,
    required this.latitude,
  });

  factory SlimApiPointDTO.fromJson(Map<String, dynamic> point) {

    return SlimApiPointDTO(
      timestamp: point['timestamp'] as int?,
      longitude: point['longitude'] as String?,
      latitude: point['latitude'] as String?,
    );
  }
}
