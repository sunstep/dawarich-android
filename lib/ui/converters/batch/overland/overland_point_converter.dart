import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_properties.dart';
import 'package:dawarich/ui/converters/batch/overland/overland_point_geometry_converter.dart';
import 'package:dawarich/ui/converters/batch/overland/overland_point_properties_converter.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_properties_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_viewmodel.dart';

extension PointDtoToEntity on OverlandPointViewModel {

  OverlandPoint toEntity() {
    OverlandPointGeometry geometry = this.geometry.toEntity();
    OverlandPointProperties properties = this.properties.toEntity();
    return OverlandPoint(type: type, geometry: geometry, properties: properties);
  }
}

extension BatchPointToViewModel on OverlandPoint {

  OverlandPointViewModel toViewModel() {
    OverlandPointGeometryViewModel geometry = this.geometry.toViewModel();
    OverlandPointPropertiesViewModel properties = this.properties.toViewModel();
    return OverlandPointViewModel(type: type, geometry: geometry, properties: properties);
  }
}

