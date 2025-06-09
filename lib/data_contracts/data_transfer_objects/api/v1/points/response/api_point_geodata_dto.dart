import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_properties_dto.dart';

class GeodataDTO {
  String? type;
  ApiPointGeometryDTO? geometry;
  ApiPointPropertiesDTO? properties;

  GeodataDTO(Map<String, dynamic> json) {
    type = json['type'];
    geometry =
        json['geometry'] != null ? ApiPointGeometryDTO(json['geometry']) : null;
    properties = json['properties'] != null
        ? ApiPointPropertiesDTO(json['properties'])
        : null;
  }
}
