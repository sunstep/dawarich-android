import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_batch.dart';
import 'package:dawarich/ui/converters/batch/dawarich/dawarich_point_converter.dart';
import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_batch_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_viewmodel.dart';

extension DawarichBatchConverter on DawarichPointBatch {

  DawarichPointBatchViewModel toViewModel() {
    List<DawarichPointViewModel> points = this.points
        .map((point) => point.toViewModel())
        .toList();
    return DawarichPointBatchViewModel(points: points);
  }
}

extension DawarichBatchDtoConverter on DawarichPointBatchViewModel {

  DawarichPointBatch toEntity() {
    List<DawarichPoint> points = this.points
        .map((pointDto) => pointDto.toEntity())
        .toList();
    return DawarichPointBatch(points: points);
  }
}