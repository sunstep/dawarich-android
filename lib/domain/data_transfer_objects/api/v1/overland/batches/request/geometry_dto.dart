class GeometryDto {
  final String type;
  final List<double> coordinates;

  GeometryDto({required this.type, required this.coordinates});

  factory GeometryDto.fromJson(Map<String, dynamic> json) {
    return GeometryDto(
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