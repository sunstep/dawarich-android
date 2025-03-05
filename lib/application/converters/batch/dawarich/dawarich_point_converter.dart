import 'package:dawarich/application/converters/batch/dawarich/dawarich_point_geometry_converter.dart';
import 'package:dawarich/application/converters/batch/dawarich/dawarich_point_properties_converter.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_properties_dto.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_properties.dart';

extension BatchPointToDto on DawarichPoint {

  DawarichPointDto toDto() {
    DawarichPointGeometryDto geometry = this.geometry.toDto();
    DawarichPointPropertiesDto properties = this.properties.toDto();
    return DawarichPointDto(type: type, geometry: geometry, properties: properties);
  }
}

extension PointDtoToEntity on DawarichPointDto {

  DawarichPoint toEntity() {
    DawarichPointGeometry geometry = this.geometry.toEntity();
    DawarichPointProperties properties = this.properties.toEntity();
    return DawarichPoint(type: type, geometry: geometry, properties: properties);
  }
}

