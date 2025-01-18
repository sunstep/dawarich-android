
import 'package:dawarich/domain/entities/api/v1/points/response/api_point_properties.dart';

class ApiPointPropertiesViewModel {

  String? city;
  String? type;
  String? state;
  int? osmId;
  String? street;
  String? country;
  String? osmKey;
  String? locality;
  String? osmType;
  String? postcode;
  String? osmValue;
  String? countrycode;
  String? housenumber;


  ApiPointPropertiesViewModel(ApiPointProperties properties) {
    city = properties.city;
    type = properties.type;
    state = properties.state;
    osmId = properties.osmId;
    street = properties.street;
    country = properties.country;
    osmKey = properties.osmKey;
    locality = properties.locality;
    osmType = properties.osmType;
    postcode = properties.postcode;
    osmValue = properties.osmValue;
    countrycode = properties.countrycode;
    housenumber = properties.housenumber;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['city'] = city;
    data['type'] = type;
    data['state'] = state;
    data['osm_id'] = osmId;
    data['street'] = street;
    data['country'] = country;
    data['osm_key'] = osmKey;
    data['locality'] = locality;
    data['osm_type'] = osmType;
    data['postcode'] = postcode;
    data['osm_value'] = osmValue;
    data['countrycode'] = countrycode;
    data['housenumber'] = housenumber;
    return data;
  }
}