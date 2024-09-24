import 'package:dawarich/models/point_geometry.dart';
import 'package:dawarich/models/point_properties.dart';


class PointCreator {

  final String type = "Feature";
  final PointGeometry geometry;
  final PointProperties properties;

  PointCreator({
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