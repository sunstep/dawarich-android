import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_properties.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/converters/point/local/local_point_geometry_converter.dart';
import 'package:dawarich/features/tracking/application/converters/point/local/local_point_properties_converter.dart';

extension LocalPointToApi on LocalPoint {
  DawarichPoint toApi() {
    DawarichPointGeometry geometry = this.geometry.toApi();
    DawarichPointProperties properties = this.properties.toApi();
    return DawarichPoint(
        type: type, geometry: geometry, properties: properties);
  }
}
