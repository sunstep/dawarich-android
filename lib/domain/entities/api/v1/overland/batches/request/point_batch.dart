import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';

class PointBatch {
  final List<Point> points;

  PointBatch({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}
