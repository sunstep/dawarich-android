import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';

class LocalPoint {
  final int id;
  final String type;
  final LocalPointGeometry geometry;
  final LocalPointProperties properties;
  final int userId;
  final bool isUploaded;

  LocalPoint(
      {required this.id,
      required this.type,
      required this.geometry,
      required this.properties,
      required this.userId,
      required this.isUploaded});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'geometry': geometry.toJson(),
      'properties': properties.toJson(),
      'userId': userId,
      'isUploaded': isUploaded,
    };
  }

  factory LocalPoint.fromJson(Map<String, dynamic> json) {
    return LocalPoint(
      id: json['id'] as int,
      type: json['type'] as String,
      geometry: LocalPointGeometry.fromJson(json['geometry']),
      properties: LocalPointProperties.fromJson(json['properties']),
      userId: json['userId'] as int,
      isUploaded: json['isUploaded'] as bool,
    );
  }
}
