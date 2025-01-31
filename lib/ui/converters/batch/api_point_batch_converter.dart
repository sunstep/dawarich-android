import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_point_batch.dart';
import 'package:dawarich/ui/converters/batch/api_point_converter.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/api_point_batch.dart';


extension BatchEntityToViewModel on ApiPointBatch {

  ApiPointBatchViewModel toViewModel() {
    List<ApiBatchPointViewModel> points = this.points
        .map((point) => point.toViewModel())
        .toList();
    return ApiPointBatchViewModel(points: points);
  }
}

extension BatchViewModelToEntity on ApiPointBatchViewModel {

  ApiPointBatch toEntity() {
    List<ApiBatchPoint> points = this.points
      .map((point) => point.toEntity())
      .toList();
    return ApiPointBatch(points: points);
  }
}
