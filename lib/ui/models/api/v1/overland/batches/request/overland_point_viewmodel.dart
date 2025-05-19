import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_properties_viewmodel.dart';

class OverlandPointViewModel {
  final String type;
  final OverlandPointGeometryViewModel geometry;
  final OverlandPointPropertiesViewModel properties;

  OverlandPointViewModel({
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