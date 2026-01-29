import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';

extension LocalPointGeometryToApi on LocalPointGeometry {
  DawarichPointGeometry toApi() {
    return DawarichPointGeometry(type: type, coordinates: [longitude, latitude]);
  }
}
