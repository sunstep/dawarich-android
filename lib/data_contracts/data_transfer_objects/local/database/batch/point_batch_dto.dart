import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/batch_point_dto.dart';

class PointBatchDto {

  final List<BatchPointDto> points;

  PointBatchDto({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}