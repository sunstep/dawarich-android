class BatchPointGeometry {
  final String type;
  final List<double> coordinates;

  BatchPointGeometry({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}