
class PointGeometryDto {

  final String type;
  final List<double> coordinates;

  PointGeometryDto({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}