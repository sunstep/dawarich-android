import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';

class LocalPoint {
  final int id;
  final String type;
  final LocalPointGeometry geometry;
  final LocalPointProperties properties;
  String get deduplicationKey => "$userId|${properties.recordTimestamp}|${geometry.longitude},${geometry.latitude}";
  final int userId;
  final bool isUploaded;

  LocalPoint(
      {required this.id,
      required this.type,
      required this.geometry,
      required this.properties,
      required this.userId,
      required this.isUploaded});

}
