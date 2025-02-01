
class BatchPointGeometryDto {

  final String type;
  final List<double> coordinates;

  BatchPointGeometryDto({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}