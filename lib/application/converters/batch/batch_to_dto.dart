import 'package:dawarich/application/entities/api/v1/overland/batches/request/batch.dart';
import 'package:dawarich/domain/data_transfer_objects/api/v1/overland/batches/request/batch_dto.dart';
import 'package:dawarich/domain/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:dawarich/application/converters/batch/point_to_dto.dart';

extension BatchConverter on Batch {

  BatchDto toDto() {
    List<PointDto> points = this.points
      .map((point) => point.toDto())
      .toList();
    return BatchDto(points: points);
  }
}