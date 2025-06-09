import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_properties.dart';
import 'package:dawarich/ui/converters/batch/dawarich/dawarich_point_geometry_converter.dart';
import 'package:dawarich/ui/converters/batch/dawarich/dawarich_point_properties_converter.dart';
import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_properties_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_viewmodel.dart';

extension BatchPointToViewModel on DawarichPoint {
  DawarichPointViewModel toViewModel() {
    DawarichPointGeometryViewModel geometry = this.geometry.toViewModel();
    DawarichPointPropertiesViewModel properties = this.properties.toViewModel();
    return DawarichPointViewModel(
        type: type, geometry: geometry, properties: properties);
  }
}

extension PointDtoToEntity on DawarichPointViewModel {
  DawarichPoint toEntity() {
    DawarichPointGeometry geometry = this.geometry.toEntity();
    DawarichPointProperties properties = this.properties.toEntity();
    return DawarichPoint(
        type: type, geometry: geometry, properties: properties);
  }
}
