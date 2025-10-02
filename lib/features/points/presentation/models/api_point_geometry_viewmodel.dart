import 'package:dawarich/core/domain/models/point/api/api_point_geometry.dart';

class ApiPointGeometryViewModel {
  String? type;
  List<double>? coordinates;

  ApiPointGeometryViewModel(ApiPointGeometry geometry) {
    type = geometry.type;
    coordinates = geometry.coordinates?.cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}
