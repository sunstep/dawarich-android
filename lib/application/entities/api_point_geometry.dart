import 'package:dawarich/domain/data_transfer_objects/api_point_geometry_dto.dart';

class ApiPointGeometry {
  String? type;
  List<double>? coordinates;

  ApiPointGeometry(ApiPointGeometryDTO dto) {
    type = dto.type;
    coordinates = dto.coordinates?.cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}