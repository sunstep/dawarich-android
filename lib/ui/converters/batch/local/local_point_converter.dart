import 'package:dawarich/domain/entities/point/batch/local/local_point.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_geometry.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_properties.dart';
import 'package:dawarich/ui/converters/batch/local/local_point_geometry_converter.dart';
import 'package:dawarich/ui/converters/batch/local/local_point_properties_converter.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_properties_viewmodel.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_viewmodel.dart';

extension BatchPointToViewModel on LocalPoint {
  LocalPointViewModel toViewModel() {
    LocalPointGeometryViewModel geometry = this.geometry.toViewModel();
    LocalPointPropertiesViewModel properties = this.properties.toViewModel();
    return LocalPointViewModel(
        id: id,
        type: type,
        geometry: geometry,
        properties: properties,
        userId: userId,
        isUploaded: isUploaded);
  }
}

extension PointDtoToEntity on LocalPointViewModel {
  LocalPoint toEntity() {
    LocalPointGeometry geometry = this.geometry.toEntity();
    LocalPointProperties properties = this.properties.toEntity();
    return LocalPoint(
        id: id,
        type: type,
        geometry: geometry,
        properties: properties,
        userId: userId,
        isUploaded: isUploaded);
  }
}
