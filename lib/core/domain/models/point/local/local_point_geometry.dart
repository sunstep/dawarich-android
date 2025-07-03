class LocalPointGeometry {
  final String type;
  final List<double> coordinates;

  LocalPointGeometry({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  factory LocalPointGeometry.fromJson(Map<String, dynamic> json) {
    return LocalPointGeometry(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}
