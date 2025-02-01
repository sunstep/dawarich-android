
import 'package:dawarich/application/converters/batch/point_geometry_converter.dart';
import 'package:dawarich/application/converters/batch/point_properties_converter.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/api_batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/batch_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/batch_point_properties_dto.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_properties.dart';

extension PointDtoToEntity on ApiBatchPointDto {

  ApiBatchPoint toEntity() {
    BatchPointGeometry geometry = this.geometry.toEntity();
    BatchPointProperties properties = this.properties.toEntity();
    return ApiBatchPoint(type: type, geometry: geometry, properties: properties);
  }
}

extension ApiBatchPointConverter on ApiBatchPoint {

  ApiBatchPointDto toDto() {
    BatchPointGeometryDto geometry = this.geometry.toDto();
    BatchPointPropertiesDto properties = this.properties.toDto();
    return ApiBatchPointDto(type: type, geometry: geometry, properties: properties);
  }
}