import 'package:dawarich/application/entities/api/v1/overland/batches/request/geometry.dart';
import 'package:dawarich/application/entities/api/v1/overland/batches/request/properties.dart';

class Point {
  final String type;
  final Geometry geometry;
  final Properties properties;

  Point({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      type: json['type'],
      geometry: Geometry.fromJson(json['geometry']),
      properties: Properties.fromJson(json['properties']),
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