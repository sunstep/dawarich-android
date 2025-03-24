import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_dto.dart';
import 'package:dawarich/application/converters/batch/overland/overland_point_converter.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_batch.dart';

extension BatchConverter on OverlandPointBatch {

  OverlandPointBatchDto toDto() {
    List<OverlandPointDto> points = this.points
        .map((point) => point.toDto())
        .toList();
    return OverlandPointBatchDto(points: points);
  }
}

extension BatchDtoConverter on OverlandPointBatchDto {

  OverlandPointBatch toEntity() {
    List<OverlandPoint> points = this.points
        .map((pointDto) => pointDto.toEntity())
        .toList();
    return OverlandPointBatch(points: points);
  }
}