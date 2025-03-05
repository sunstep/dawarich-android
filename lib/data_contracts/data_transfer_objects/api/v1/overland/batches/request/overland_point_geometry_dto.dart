
class OverlandPointGeometryDto {

  final String type;
  final List<double> coordinates;

  OverlandPointGeometryDto({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}