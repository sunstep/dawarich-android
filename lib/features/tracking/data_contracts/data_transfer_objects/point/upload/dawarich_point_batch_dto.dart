import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/upload/dawarich_point_dto.dart';

class DawarichPointBatchDto {

  final List<DawarichPointDto> points;
  DawarichPointBatchDto({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((p) => p.toJson()).toList(),
    };
  }
}
