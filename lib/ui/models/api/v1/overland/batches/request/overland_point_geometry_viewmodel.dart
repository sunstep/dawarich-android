class OverlandPointGeometryViewModel {
  final String type;
  final List<double> coordinates;

  OverlandPointGeometryViewModel({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}