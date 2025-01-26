import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';

class PointBatch {
  final List<Point> points;

  PointBatch({required this.points});

  factory PointBatch.fromJson(Map<String, dynamic> json) {
    return PointBatch(
      points: (json['locations'] as List)
          .map((item) => Point.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}
