
class DawarichPointGeometry {

  final String type;
  final List<double> coordinates;

  DawarichPointGeometry({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}