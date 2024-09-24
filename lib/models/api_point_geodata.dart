import 'api_point_geometry.dart';
import 'api_point_properties.dart';

class Geodata {
  String? type;
  ApiPointGeometry? geometry;
  ApiPointProperties? properties;


  Geodata(Map<String, dynamic> json) {
    type = json['type'];
    geometry = json['geometry'] != null
        ?  ApiPointGeometry(json['geometry'])
        : null;
    properties = json['properties'] != null
        ?  ApiPointProperties(json['properties'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
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