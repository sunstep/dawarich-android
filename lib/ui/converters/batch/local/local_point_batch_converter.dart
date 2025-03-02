import 'package:dawarich/domain/entities/point/batch/local/local_point.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_batch.dart';
import 'package:dawarich/ui/converters/batch/local/local_point_converter.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_batch_viewmodel.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_viewmodel.dart';

extension LocalBatchConverter on LocalPointBatch {

  LocalPointBatchViewModel toViewModel() {
    List<LocalPointViewModel> points = this.points
        .map((point) => point.toViewModel())
        .toList();
    return LocalPointBatchViewModel(points: points);
  }
}

extension LocalBatchViewModelConverter on LocalPointBatchViewModel {

  LocalPointBatch toEntity() {
    List<LocalPoint> points = this.points
        .map((pointDto) => pointDto.toEntity())
        .toList();
    return LocalPointBatch(points: points);
  }
}