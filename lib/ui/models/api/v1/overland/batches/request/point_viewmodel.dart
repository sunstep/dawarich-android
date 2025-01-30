import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_properties_viewmodel.dart';

class PointViewModel {
  final int id;
  final String type;
  final PointGeometryViewModel geometry;
  final PointPropertiesViewModel properties;

  PointViewModel({
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