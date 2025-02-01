import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/batch_point_geometry_dto.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_geometry.dart';

extension PointGeometryDtoToEntity on BatchPointGeometryDto {

  BatchPointGeometry toEntity() {
    return BatchPointGeometry(type: type, coordinates: coordinates);
  }
}

extension PointGeometryToDto on BatchPointGeometry {

  BatchPointGeometryDto toDto() {
    return BatchPointGeometryDto(type: type, coordinates: coordinates);
  }
}

