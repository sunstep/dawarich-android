import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';

class DawarichPointBatch {
  final List<DawarichPoint> points;

  DawarichPointBatch({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}
