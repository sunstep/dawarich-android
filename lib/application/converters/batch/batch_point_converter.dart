import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/batch_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/batch_point_properties_dto.dart';
import 'package:dawarich/application/converters/batch/point_geometry_converter.dart';
import 'package:dawarich/application/converters/batch/point_properties_converter.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_properties.dart';
import 'package:dawarich/domain/entities/local/database/batch/batch_point.dart';

extension PointDtoToEntity on BatchPointDto {

  BatchPoint toEntity() {
    BatchPointGeometry geometry = this.geometry.toEntity();
    BatchPointProperties properties = this.properties.toEntity();
    return BatchPoint(id: id?? 0, type: type, geometry: geometry, properties: properties);
  }
}

extension BatchPointToDto on BatchPoint {

  BatchPointDto toDto() {
    BatchPointGeometryDto geometry = this.geometry.toDto();
    BatchPointPropertiesDto properties = this.properties.toDto();
    return BatchPointDto(id: id, type: type, geometry: geometry, properties: properties);
  }
}