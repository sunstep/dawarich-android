import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point.dart';

class OverlandPointBatch {

  final List<OverlandPoint> points;

  OverlandPointBatch({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}
