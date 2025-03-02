import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_geometry.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_geometry_viewmodel.dart';

extension OverlandPointGeometryDtoToEntity on OverlandPointGeometryViewModel {

  OverlandPointGeometry toEntity() {
    return OverlandPointGeometry(type: type, coordinates: coordinates);
  }
}

extension OverlandPointGeometryToViewModel on OverlandPointGeometry {

  OverlandPointGeometryViewModel toViewModel() {
    return OverlandPointGeometryViewModel(type: type, coordinates: coordinates);
  }
}

