import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';

class Batch {
  final List<Point> points;

  Batch({required this.points});

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
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
