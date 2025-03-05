import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_dto.dart';

class OverlandPointBatchDto {

  final List<OverlandPointDto> points;

  OverlandPointBatchDto({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}