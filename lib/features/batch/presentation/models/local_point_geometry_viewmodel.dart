class LocalPointGeometryViewModel {
  final String type;
  final double longitude;
  final double latitude;

  LocalPointGeometryViewModel({
    required this.type,
    required this.longitude,
    required this.latitude});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'longitude': longitude,
      'latitude': latitude
    };
  }
}
