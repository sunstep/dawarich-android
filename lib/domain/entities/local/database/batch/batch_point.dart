import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_properties.dart';

class BatchPoint {

  final int? id;
  final String type;
  final BatchPointGeometry geometry;
  final BatchPointProperties properties;

  BatchPoint({
    this.id,
    required this.type,
    required this.geometry,
    required this.properties,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'geometry': geometry.toJson(),
      'properties': properties.toJson(),
    };
  }
}