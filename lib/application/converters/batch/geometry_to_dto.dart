
import 'package:dawarich/application/entities/api/v1/overland/batches/request/geometry.dart';
import 'package:dawarich/domain/data_transfer_objects/api/v1/overland/batches/request/geometry_dto.dart';

extension GeometryToDto on Geometry {

  GeometryDto toDto() {
    return GeometryDto(type: type, coordinates: coordinates);
  }
}