import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_batch.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:dawarich/application/converters/batch/point_converter.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_batch_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_viewmodel.dart';

extension BatchEntityToViewModel on PointBatch {

  PointBatchViewModel toViewModel() {
    List<PointViewModel> points = this.points
        .map((point) => point.toViewModel())
        .toList();
    return PointBatchViewModel(points: points);
  }
}

extension BatchConverter on PointBatch {

  PointBatchDto toDto() {
    List<PointDto> points = this.points
      .map((point) => point.toDto())
      .toList();
    return PointBatchDto(points: points);
  }

  
}

extension BatchDtoConverter on PointBatchDto {

  PointBatch toEntity() {
    List<Point> points = this.points
        .map((pointDto) => pointDto.toEntity())
        .toList();
    return PointBatch(points: points);
  }
  
}

