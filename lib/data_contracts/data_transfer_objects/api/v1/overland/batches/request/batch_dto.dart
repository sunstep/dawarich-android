
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';

class BatchDto {

  final List<PointDto> points;

  BatchDto({required this.points});

  factory BatchDto.fromJson(Map<String, dynamic> json) {
    return BatchDto(
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