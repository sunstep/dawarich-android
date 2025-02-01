import 'package:dawarich/domain/entities/local/database/batch/batch_point.dart';

class PointBatch {

  final List<BatchPoint> points;

  PointBatch({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}