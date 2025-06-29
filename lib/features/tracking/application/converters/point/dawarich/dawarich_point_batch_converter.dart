import 'package:dawarich/features/tracking/application/converters/point/dawarich/dawarich_point_converter.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_dto.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_batch.dart';

extension BatchConverter on DawarichPointBatch {
  DawarichPointBatchDto toDto() {
    List<DawarichPointDto> points =
        this.points.map((point) => point.toDto()).toList();
    return DawarichPointBatchDto(points: points);
  }
}

extension BatchDtoConverter on DawarichPointBatchDto {
  DawarichPointBatch toEntity() {
    List<DawarichPoint> points =
        this.points.map((pointDto) => pointDto.toEntity()).toList();
    return DawarichPointBatch(points: points);
  }
}
