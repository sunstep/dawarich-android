import 'package:dawarich/ui/models/api/v1/overland/batches/request/batch_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/batch_point_properties_viewmodel.dart';

class ApiBatchPointViewModel {
  final String type;
  final BatchPointGeometryViewModel geometry;
  final BatchPointPropertiesViewModel properties;

  ApiBatchPointViewModel({
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