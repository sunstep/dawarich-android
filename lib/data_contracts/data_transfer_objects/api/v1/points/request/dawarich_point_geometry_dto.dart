
class DawarichPointGeometryDto {

  final String type;
  final List<double> coordinates;

  DawarichPointGeometryDto({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}