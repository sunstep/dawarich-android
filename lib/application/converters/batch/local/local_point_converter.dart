import 'package:dawarich/application/converters/batch/local/local_point_geometry_converter.dart';
import 'package:dawarich/application/converters/batch/local/local_point_properties_converter.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_properties_dto.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_geometry.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_properties.dart';


extension LocalBatchPointToDto on LocalPoint {

  LocalPointDto toDto() {
    LocalPointGeometryDto geometry = this.geometry.toDto();
    LocalPointPropertiesDto properties = this.properties.toDto();
    return LocalPointDto(id: id, type: type, geometry: geometry, properties: properties);
  }
}

extension LocalPointDtoToEntity on LocalPointDto {

  LocalPoint toEntity() {
    LocalPointGeometry geometry = this.geometry.toEntity();
    LocalPointProperties properties = this.properties.toEntity();
    return LocalPoint(id: id, type: type, geometry: geometry, properties: properties);
  }
}

