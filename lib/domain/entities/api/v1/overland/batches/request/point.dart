import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_properties.dart';

class Point {
  final String type;
  final PointGeometry geometry;
  final PointProperties properties;

  Point({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      type: json['type'],
      geometry: PointGeometry.fromJson(json['geometry']),
      properties: PointProperties.fromJson(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'geometry': geometry.toJson(),
      'properties': properties.toJson(),
    };
  }
}