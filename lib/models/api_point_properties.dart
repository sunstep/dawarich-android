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


  ApiPointProperties(Map<String, dynamic> json) {
    city = json['city'];
    type = json['type'];
    state = json['state'];
    osmId = json['osm_id'];
    street = json['street'];
    country = json['country'];
    osmKey = json['osm_key'];
    locality = json['locality'];
    osmType = json['osm_type'];
    postcode = json['postcode'];
    osmValue = json['osm_value'];
    countrycode = json['countrycode'];
    housenumber = json['housenumber'];
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