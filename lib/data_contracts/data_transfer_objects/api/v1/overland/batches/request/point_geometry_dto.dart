class PointGeometryDto {

  final String type;
  final List<double> coordinates;

  PointGeometryDto({required this.type, required this.coordinates});

  factory PointGeometryDto.fromJson(Map<String, dynamic> json) {
    return PointGeometryDto(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}