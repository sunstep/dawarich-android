
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_geometry_dto.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_geometry.dart';

extension PointGeometryToDto on PointGeometry {

  PointGeometryDto toDto() {
    return PointGeometryDto(type: type, coordinates: coordinates);
  }
}

extension PointGeometryDtoToEntity on PointGeometryDto {

  PointGeometry toEntity() {
    return PointGeometry(type: type, coordinates: coordinates);
  }
}