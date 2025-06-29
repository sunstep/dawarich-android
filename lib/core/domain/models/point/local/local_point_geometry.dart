class LocalPointGeometry {
  final String type;
  final List<double> coordinates;

  LocalPointGeometry({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
