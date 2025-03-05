import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_properties_dto.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_properties.dart';
import 'package:dawarich/application/converters/batch/overland/overland_point_geometry_converter.dart';
import 'package:dawarich/application/converters/batch/overland/overland_point_properties_converter.dart';

extension BatchPointToDto on OverlandPoint {

  OverlandPointDto toDto() {
    OverlandPointGeometryDto geometry = this.geometry.toDto();
    OverlandPointPropertiesDto properties = this.properties.toDto();
    return OverlandPointDto(type: type, geometry: geometry, properties: properties);
  }
}

extension PointDtoToEntity on OverlandPointDto {

  OverlandPoint toEntity() {
    OverlandPointGeometry geometry = this.geometry.toEntity();
    OverlandPointProperties properties = this.properties.toEntity();
    return OverlandPoint(type: type, geometry: geometry, properties: properties);
  }
}

