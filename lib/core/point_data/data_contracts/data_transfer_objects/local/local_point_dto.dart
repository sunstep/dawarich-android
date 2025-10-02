import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_properties_dto.dart';

class LocalPointDto {
  final int id;
  final String type;
  final LocalPointGeometryDto geometry;
  final LocalPointPropertiesDto properties;
  String get deduplicationKey => '$userId|${properties.timestamp}|${geometry.longitude},${geometry.latitude}';
  final int userId;
  final bool isUploaded;

  LocalPointDto(
      {required this.id,
      required this.type,
      required this.geometry,
      required this.properties,
      required this.userId,
      required this.isUploaded});

  LocalPointDto copyWith({
    int? id,
    String? type,
    LocalPointGeometryDto? geometry,
    LocalPointPropertiesDto? properties,
    int? userId,
    bool? isUploaded,
  }) {
    return LocalPointDto(
      id:           id           ?? this.id,
      type:         type         ?? this.type,
      geometry:     geometry     ?? this.geometry,
      properties:   properties   ?? this.properties,
      userId:       userId       ?? this.userId,
      isUploaded:   isUploaded   ?? this.isUploaded,
    );
  }
}
