import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';

extension LocalPointGeometryToDto on LocalPointGeometry {
  LocalPointGeometryDto toDto() {
    return LocalPointGeometryDto(
        type: type,
        longitude: longitude,
        latitude: latitude
    );
  }
}

extension LocalPointGeometryToApi on LocalPointGeometry {
  DawarichPointGeometry toApi() {
    return DawarichPointGeometry(type: type, coordinates: [longitude, latitude]);
  }
}

extension LocalPointGeometryDtoToEntity on LocalPointGeometryDto {
  LocalPointGeometry toDomain() {
    return LocalPointGeometry(
        type: type,
        longitude: longitude,
        latitude: latitude
    );
  }
}
