import 'package:dawarich/core/point_data/data_transfer_objects/api/api_point_properties_dto.dart';

class ApiPointProperties {
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

  ApiPointProperties(ApiPointPropertiesDTO dto) {
    city = dto.city;
    type = dto.type;
    state = dto.state;
    osmId = dto.osmId;
    street = dto.street;
    country = dto.country;
    osmKey = dto.osmKey;
    locality = dto.locality;
    osmType = dto.osmType;
    postcode = dto.postcode;
    osmValue = dto.osmValue;
    countrycode = dto.countrycode;
    housenumber = dto.houseNumber;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
