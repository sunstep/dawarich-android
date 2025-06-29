class ApiPointPropertiesDTO {
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
  String? houseNumber;

  ApiPointPropertiesDTO(Map<String, dynamic> json) {
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
    houseNumber = json['housenumber'];
  }
}
