
import 'package:dawarich/application/entities/api/v1/overland/batches/request/point.dart';
import 'package:dawarich/domain/data_transfer_objects/api/v1/overland/batches/request/geometry_dto.dart';
import 'package:dawarich/domain/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:dawarich/domain/data_transfer_objects/api/v1/overland/batches/request/properties_dto.dart';
import 'package:dawarich/application/converters/batch/geometry_to_dto.dart';
import 'package:dawarich/application/converters/batch/properties_to_dto.dart';

extension PointToDto on Point {

  PointDto toDto() {
    GeometryDto geometry = this.geometry.toDto();
    PropertiesDto properties = this.properties.toDto();
    return PointDto(type: type, geometry: geometry, properties: properties);
  }
}