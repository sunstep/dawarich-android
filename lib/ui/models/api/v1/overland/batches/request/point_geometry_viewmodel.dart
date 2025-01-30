class PointGeometryViewModel {
  final String type;
  final List<double> coordinates;

  PointGeometryViewModel({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}