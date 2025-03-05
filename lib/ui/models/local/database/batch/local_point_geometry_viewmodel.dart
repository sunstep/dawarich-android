class LocalPointGeometryViewModel {

  final String type;
  final List<double> coordinates;

  LocalPointGeometryViewModel({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}