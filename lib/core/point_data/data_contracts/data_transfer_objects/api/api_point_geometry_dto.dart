class ApiPointGeometryDTO {
  String? type;
  List<double>? coordinates;

  ApiPointGeometryDTO(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }
}
