import 'point_geometry.dart';
import 'point_properties.dart';

abstract class Point {
  String get type;
  PointGeometry get geometry;
  PointProperties get properties;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'geometry': geometry.toJson(),
      'properties': properties.toJson(),
    };
  }
}
