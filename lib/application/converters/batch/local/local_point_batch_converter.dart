import 'package:dawarich/application/converters/batch/local/local_point_converter.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_batch.dart';

extension LocalBatchConverter on LocalPointBatch {

  LocalPointBatchDto toDto() {
    List<LocalPointDto> points = this.points
        .map((point) => point.toDto())
        .toList();
    return LocalPointBatchDto(points: points);
  }
}

extension LocalBatchDtoConverter on LocalPointBatchDto {

  LocalPointBatch toEntity() {
    List<LocalPoint> points = this.points
        .map((pointDto) => pointDto.toDomain())
        .toList();
    return LocalPointBatch(points: points);
  }
}