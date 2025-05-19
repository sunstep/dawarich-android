import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_geometry.dart';
import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_geometry_viewmodel.dart';

extension DawarichPointGeometryToViewModel on DawarichPointGeometry {

  DawarichPointGeometryViewModel toViewModel() {
    return DawarichPointGeometryViewModel(type: type, coordinates: coordinates);
  }
}

extension DawarichPointGeometryDtoToEntity on DawarichPointGeometryViewModel {

  DawarichPointGeometry toEntity() {
    return DawarichPointGeometry(type: type, coordinates: coordinates);
  }
}

