import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_properties_viewmodel.dart';

class DawarichPointViewModel {
  final String type;
  final DawarichPointGeometryViewModel geometry;
  final DawarichPointPropertiesViewModel properties;

  DawarichPointViewModel({
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
