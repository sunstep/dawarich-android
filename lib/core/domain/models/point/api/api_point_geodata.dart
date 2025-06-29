import 'package:dawarich/core/domain/models/point/api/api_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/api/api_point_properties.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_geodata_dto.dart';

class Geodata {
  String? type;
  ApiPointGeometry? geometry;
  ApiPointProperties? properties;

  Geodata(GeodataDTO dto) {
    type = dto.type;
    geometry = dto.geometry != null ? ApiPointGeometry(dto.geometry!) : null;
    properties =
        dto.properties != null ? ApiPointProperties(dto.properties!) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (geometry != null) {
      data['geometry'] = geometry!.toJson();
    }
    if (properties != null) {
      data['properties'] = properties!.toJson();
    }
    return data;
  }
}
