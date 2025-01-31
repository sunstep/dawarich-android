import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_properties.dart';
import 'package:dawarich/ui/converters/batch/point_geometry_converter.dart';
import 'package:dawarich/ui/converters/batch/point_properties_converter.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/batch_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/batch_point_properties_viewmodel.dart';

extension PointEntityToViewModel on ApiBatchPoint {

  ApiBatchPointViewModel toViewModel() {
    BatchPointGeometryViewModel geometry = this.geometry.toViewModel();
    BatchPointPropertiesViewModel properties = this.properties.toViewModel();
    return ApiBatchPointViewModel(type: type, geometry: geometry, properties: properties);
  }
}

extension PointViewModelToEntity on ApiBatchPointViewModel {

  ApiBatchPoint toEntity() {
    BatchPointGeometry geometry = this.geometry.toEntity();
    BatchPointProperties properties = this.properties.toEntity();
    return ApiBatchPoint(type: type, geometry: geometry, properties: properties);
  }
}
