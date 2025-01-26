
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';

class PointBatchDto {

  final List<PointDto> points;

  PointBatchDto({required this.points});

  factory PointBatchDto.fromJson(Map<String, dynamic> json) {
    return PointBatchDto(
      points: (json['locations'] as List)
          .map((item) => PointDto.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}