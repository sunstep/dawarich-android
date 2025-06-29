import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';

extension LocalPointGeometryToDto on LocalPointGeometry {
  LocalPointGeometryDto toDto() {
    return LocalPointGeometryDto(type: type, coordinates: coordinates);
  }
}

extension LocalPointGeometryToApi on LocalPointGeometry {
  DawarichPointGeometry toApi() {
    return DawarichPointGeometry(type: type, coordinates: coordinates);
  }
}

extension LocalPointGeometryDtoToEntity on LocalPointGeometryDto {
  LocalPointGeometry toEntity() {
    return LocalPointGeometry(type: type, coordinates: coordinates);
  }
}
