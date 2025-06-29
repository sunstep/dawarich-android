import 'package:dawarich/features/tracking/application/converters/point/local/local_point_geometry_converter.dart';
import 'package:dawarich/features/tracking/application/converters/point/local/local_point_properties_converter.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_properties_dto.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_properties.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';

extension LocalBatchPointToDto on LocalPoint {
  LocalPointDto toDto() {
    LocalPointGeometryDto geometry = this.geometry.toDto();
    LocalPointPropertiesDto properties = this.properties.toDto();
    return LocalPointDto(
        id: id,
        type: type,
        geometry: geometry,
        properties: properties,
        userId: userId,
        isUploaded: isUploaded);
  }
}

extension LocalPointToApi on LocalPoint {
  DawarichPoint toApi() {
    DawarichPointGeometry geometry = this.geometry.toApi();
    DawarichPointProperties properties = this.properties.toApi();
    return DawarichPoint(
        type: type, geometry: geometry, properties: properties);
  }
}

extension LocalPointDtoToEntity on LocalPointDto {
  LocalPoint toDomain() {
    LocalPointGeometry geometry = this.geometry.toEntity();
    LocalPointProperties properties = this.properties.toEntity();
    return LocalPoint(
        id: id,
        type: type,
        geometry: geometry,
        properties: properties,
        userId: userId,
        isUploaded: isUploaded);
  }
}
