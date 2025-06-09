import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_properties.dart';

class DawarichPoint {
  final String type;
  final DawarichPointGeometry geometry;
  final DawarichPointProperties properties;

  DawarichPoint({
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
