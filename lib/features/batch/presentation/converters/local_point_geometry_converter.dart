import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';
import 'package:dawarich/features/batch/presentation/models/local_point_geometry_viewmodel.dart';

extension LocalPointGeometryEntityToViewModel on LocalPointGeometry {
  LocalPointGeometryViewModel toViewModel() {
    return LocalPointGeometryViewModel(
        type: type,
        longitude: longitude,
        latitude: latitude
    );
  }
}

extension LocalPointGeometryViewModelToEntity on LocalPointGeometryViewModel {
  LocalPointGeometry toDomain() {
    return LocalPointGeometry(
        type: type,
        longitude: longitude,
        latitude: latitude
    );
  }
}
