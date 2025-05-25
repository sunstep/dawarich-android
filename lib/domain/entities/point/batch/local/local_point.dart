import 'package:dawarich/domain/entities/point/batch/local/local_point_geometry.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_properties.dart';

class LocalPoint {

  final int id;
  final String type;
  final LocalPointGeometry geometry;
  final LocalPointProperties properties;
  final int userId;
  final bool isUploaded;

  LocalPoint({
    required this.id,
    required this.type,
    required this.geometry,
    required this.properties,
    required this.userId,
    required this.isUploaded
  });

}