import 'package:dawarich/domain/entities/point/batch/local/local_point.dart';

class LocalPointBatch {

  final List<LocalPoint> points;

  LocalPointBatch({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}