import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_geometry_dto.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_geometry.dart';

extension PointGeometryDtoToEntity on OverlandPointGeometryDto {

  OverlandPointGeometry toEntity() {
    return OverlandPointGeometry(type: type, coordinates: coordinates);
  }
}

extension PointGeometryToDto on OverlandPointGeometry {

  OverlandPointGeometryDto toDto() {
    return OverlandPointGeometryDto(type: type, coordinates: coordinates);
  }
}

