import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/api_batch_point_dto.dart';

class ApiPointBatchDto {

  final List<ApiBatchPointDto> points;

  ApiPointBatchDto({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}