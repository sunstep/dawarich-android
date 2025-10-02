import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_properties.dart';

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
