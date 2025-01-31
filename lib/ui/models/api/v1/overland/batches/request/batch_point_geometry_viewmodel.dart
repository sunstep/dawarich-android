class BatchPointGeometryViewModel {
  final String type;
  final List<double> coordinates;

  BatchPointGeometryViewModel({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}