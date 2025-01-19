
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/properties_dto.dart';

class PointDto {

  final String type;
  final GeometryDto geometry;
  final PropertiesDto properties;

  PointDto({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory PointDto.fromJson(Map<String, dynamic> json) {
    return PointDto(
      type: json['type'],
      geometry: GeometryDto.fromJson(json['geometry']),
      properties: PropertiesDto.fromJson(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'geometry': geometry.toJson(),
      'properties': properties.toJson(),
    };
  }
}