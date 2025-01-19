import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_batch.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:dawarich/application/converters/batch/point_converter.dart';

extension BatchConverter on PointBatch {

  PointBatchDto toDto() {
    List<PointDto> points = this.points
      .map((point) => point.toDto())
      .toList();
    return PointBatchDto(points: points);
  }
}