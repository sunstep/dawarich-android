class PointGeometry {
  final String type;
  final List<double> coordinates;

  PointGeometry({required this.type, required this.coordinates});

  factory PointGeometry.fromJson(Map<String, dynamic> json) {
    return PointGeometry(
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