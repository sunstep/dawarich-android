import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_geometry_dto.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_geometry.dart';

extension PointGeometryToDto on DawarichPointGeometry {

  DawarichPointGeometryDto toDto() {
    return DawarichPointGeometryDto(type: type, coordinates: coordinates);
  }
}

extension PointGeometryDtoToEntity on DawarichPointGeometryDto {

  DawarichPointGeometry toEntity() {
    return DawarichPointGeometry(type: type, coordinates: coordinates);
  }
}

