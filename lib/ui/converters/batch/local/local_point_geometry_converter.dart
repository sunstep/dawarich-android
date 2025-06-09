import 'package:dawarich/domain/entities/point/batch/local/local_point_geometry.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_geometry_viewmodel.dart';

extension LocalPointGeometryEntityToViewModel on LocalPointGeometry {
  LocalPointGeometryViewModel toViewModel() {
    return LocalPointGeometryViewModel(type: type, coordinates: coordinates);
  }
}

extension LocalPointGeometryViewModelToEntity on LocalPointGeometryViewModel {
  LocalPointGeometry toEntity() {
    return LocalPointGeometry(type: type, coordinates: coordinates);
  }
}
