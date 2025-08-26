class LocalPointGeometry {
  final String type;
  final double longitude;
  final double latitude;

  LocalPointGeometry({
    required this.type,
    required this.longitude,
    required this.latitude});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  factory LocalPointGeometry.fromJson(Map<String, dynamic> json) {
    return LocalPointGeometry(
      type: json['type'] as String,
      longitude: json['longitude'] as double,
      latitude: json['latitude'] as double,
    );
  }
}
