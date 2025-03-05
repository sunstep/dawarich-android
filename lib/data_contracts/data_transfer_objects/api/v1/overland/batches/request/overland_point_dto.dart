import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_properties_dto.dart';

class OverlandPointDto {

  final String type;
  final OverlandPointGeometryDto geometry;
  final OverlandPointPropertiesDto properties;

  OverlandPointDto({
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