import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_properties_dto.dart';
import 'package:dawarich/application/converters/batch/point_geometry_converter.dart';
import 'package:dawarich/application/converters/batch/point_properties_converter.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_properties.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_properties_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_viewmodel.dart';

extension PointEntityToViewModel on Point {

  PointViewModel toViewModel() {
    PointGeometryViewModel geometry = this.geometry.toViewModel();
    PointPropertiesViewModel properties = this.properties.toViewModel();
    return PointViewModel(id: id, type: type, geometry: geometry, properties: properties);
  }
}

extension PointViewModelToEntity on PointViewModel {

  Point toEntity() {
    PointGeometry geometry = this.geometry.toEntity();
    PointProperties properties = this.properties.toEntity();
    return Point(id: id, type: type, geometry: geometry, properties: properties);
  }
}


extension PointDtoToEntity on PointDto {

  Point toEntity() {
    PointGeometry geometry = this.geometry.toEntity();
    PointProperties properties = this.properties.toEntity();
    return Point(id: id?? 0, type: type, geometry: geometry, properties: properties);
  }
}

extension PointToDto on Point {

  PointDto toDto() {
    PointGeometryDto geometry = this.geometry.toDto();
    PointPropertiesDto properties = this.properties.toDto();
    return PointDto(id: id, type: type, geometry: geometry, properties: properties);
  }
}