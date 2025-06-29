import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';
import 'package:dawarich/features/batch/presentation/converters/local_point_geometry_converter.dart';
import 'package:dawarich/features/batch/presentation/converters/local_point_properties_converter.dart';
import 'package:dawarich/features/batch/presentation/models/local_point_geometry_viewmodel.dart';
import 'package:dawarich/features/batch/presentation/models/local_point_properties_viewmodel.dart';
import 'package:dawarich/features/batch/presentation/models/local_point_viewmodel.dart';

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
  LocalPoint toDomain() {
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
