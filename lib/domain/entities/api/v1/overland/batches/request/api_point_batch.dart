import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_batch_point.dart';

class ApiPointBatch {

  final List<ApiBatchPoint> points;

  ApiPointBatch({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}
