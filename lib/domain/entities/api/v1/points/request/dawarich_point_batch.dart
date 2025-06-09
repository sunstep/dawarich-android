import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point.dart';

class DawarichPointBatch {
  final List<DawarichPoint> points;

  DawarichPointBatch({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}
