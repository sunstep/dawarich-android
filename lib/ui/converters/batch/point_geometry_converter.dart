import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_geometry.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/batch_point_geometry_viewmodel.dart';

extension PointGeometryEntityToViewmodel on BatchPointGeometry {

  BatchPointGeometryViewModel toViewModel() {
    return BatchPointGeometryViewModel(type: type, coordinates: coordinates);
  }
}

extension PointGeometryViewModelToEntity on BatchPointGeometryViewModel {

  BatchPointGeometry toEntity() {
    return BatchPointGeometry(type: type, coordinates: coordinates);
  }
}

