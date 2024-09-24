class PointGeometry {
  final String type = "Point";
  final List<double> coordinates;

  PointGeometry({
    required this.coordinates,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}