import 'package:dawarich/domain/entities/api/v1/points/response/api_point_geodata.dart';
import 'package:dawarich/ui/models/api/v1/points/response/api_point_geometry_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/points/response/api_point_properties_viewmodel.dart';

class GeoDataViewModel {

  String? type;
  ApiPointGeometryViewModel? geometry;
  ApiPointPropertiesViewModel? properties;

  GeoDataViewModel(Geodata geodata) {
    type = geodata.type;
    geometry = geodata.geometry != null
        ?  ApiPointGeometryViewModel(geodata.geometry!)
        : null;
    properties = geodata.properties != null
        ?  ApiPointPropertiesViewModel(geodata.properties!)
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