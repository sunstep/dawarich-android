import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_properties.dart';

class OverlandPoint {
  final String type;
  final OverlandPointGeometry geometry;
  final OverlandPointProperties properties;

  OverlandPoint({
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