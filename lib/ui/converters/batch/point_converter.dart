import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_properties.dart';
import 'package:dawarich/domain/entities/local/database/batch/batch_point.dart';
import 'package:dawarich/ui/converters/batch/point_geometry_converter.dart';
import 'package:dawarich/ui/converters/batch/point_properties_converter.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/batch_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/batch_point_properties_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_viewmodel.dart';

extension PointEntityToViewModel on BatchPoint {

  BatchPointViewModel toViewModel() {
    BatchPointGeometryViewModel geometry = this.geometry.toViewModel();
    BatchPointPropertiesViewModel properties = this.properties.toViewModel();
    return BatchPointViewModel(id: id?? 0, type: type, geometry: geometry, properties: properties);
  }
}

extension PointViewModelToEntity on BatchPointViewModel {

  BatchPoint toEntity() {
    BatchPointGeometry geometry = this.geometry.toEntity();
    BatchPointProperties properties = this.properties.toEntity();
    return BatchPoint(id: id, type: type, geometry: geometry, properties: properties);
  }
}

extension LocalPointToApi on BatchPointViewModel {
  ApiBatchPointViewModel toApi() {
    return ApiBatchPointViewModel(
      type: type,
      geometry: geometry,
      properties: properties,
    );
  }
}