import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';

class LocalPointBatchDto {

  final List<LocalPointDto> points;

  LocalPointBatchDto({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}