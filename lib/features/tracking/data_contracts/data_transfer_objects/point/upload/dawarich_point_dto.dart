import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/upload/dawarich_point_geometry_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/upload/dawarich_point_properties_dto.dart';

class DawarichPointDto {
  final String type;
  final DawarichPointGeometryDto geometry;
  final DawarichPointPropertiesDto properties;

  DawarichPointDto({
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
