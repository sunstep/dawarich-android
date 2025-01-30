import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_properties.dart';

class Point {
  final int id;
  final String type;
  final PointGeometry geometry;
  final PointProperties properties;

  Point({
    required this.id,
    required this.type,
    required this.geometry,
    required this.properties,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'geometry': geometry.toJson(),
      'properties': properties.toJson(),
    };
  }
}