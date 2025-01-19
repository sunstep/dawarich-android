
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/geometry_dto.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/geometry.dart';

extension GeometryToDto on Geometry {

  GeometryDto toDto() {
    return GeometryDto(type: type, coordinates: coordinates);
  }
}