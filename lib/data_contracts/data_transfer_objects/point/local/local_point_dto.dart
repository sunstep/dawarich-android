import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_properties_dto.dart';

class LocalPointDto {

  final int id;
  final String type;
  final LocalPointGeometryDto geometry;
  final LocalPointPropertiesDto properties;
  final int userId;
  final bool isUploaded;

  LocalPointDto({
    required this.id,
    required this.type,
    required this.geometry,
    required this.properties,
    required this.userId,
    required this.isUploaded
  });

}