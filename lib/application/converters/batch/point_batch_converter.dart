import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/point_batch_dto.dart';
import 'package:dawarich/application/converters/batch/batch_point_converter.dart';
import 'package:dawarich/domain/entities/local/database/batch/batch_point.dart';
import 'package:dawarich/domain/entities/local/database/batch/point_batch.dart';

extension BatchConverter on PointBatch {

  PointBatchDto toDto() {
    List<BatchPointDto> points = this.points
        .map((point) => point.toDto())
        .toList();
    return PointBatchDto(points: points);
  }
}

extension BatchDtoConverter on PointBatchDto {

  PointBatch toEntity() {
    List<BatchPoint> points = this.points
        .map((pointDto) => pointDto.toEntity())
        .toList();
    return PointBatch(points: points);
  }
}