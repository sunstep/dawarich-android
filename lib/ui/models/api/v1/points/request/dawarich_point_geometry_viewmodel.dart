
class DawarichPointGeometryViewModel {

  final String type;
  final List<double> coordinates;

  DawarichPointGeometryViewModel({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}