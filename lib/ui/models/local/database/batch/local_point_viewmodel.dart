import 'package:dawarich/ui/models/local/database/batch/local_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_properties_viewmodel.dart';

class LocalPointViewModel {

  final int id;
  final String type;
  final LocalPointGeometryViewModel geometry;
  final LocalPointPropertiesViewModel properties;

  LocalPointViewModel({
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