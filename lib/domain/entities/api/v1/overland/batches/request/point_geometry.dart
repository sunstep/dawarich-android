class PointGeometry {
  final String type;
  final List<double> coordinates;

  PointGeometry({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}