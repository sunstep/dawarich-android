class OverlandPointGeometry {
  final String type;
  final List<double> coordinates;

  OverlandPointGeometry({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}