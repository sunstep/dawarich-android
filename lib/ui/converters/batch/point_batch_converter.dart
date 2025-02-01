import 'package:dawarich/domain/entities/local/database/batch/batch_point.dart';
import 'package:dawarich/domain/entities/local/database/batch/point_batch.dart';
import 'package:dawarich/ui/converters/batch/point_converter.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/api_point_batch.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_batch_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_viewmodel.dart';
import 'package:intl/intl.dart';

extension BatchEntityToViewModel on PointBatch {

  PointBatchViewModel toViewModel() {
    List<BatchPointViewModel> points = this.points
        .map((point) => point.toViewModel())
        .toList();
    return PointBatchViewModel(points: points);
  }
}

extension BatchViewModelToEntity on PointBatchViewModel {

  PointBatch toEntity() {
    List<BatchPoint> points = this.points
      .map((point) => point.toEntity())
      .toList();
    return PointBatch(points: points);
  }
}

extension LocalBatchToApi on PointBatchViewModel {
  ApiPointBatchViewModel toApi() {
      List<ApiBatchPointViewModel> points = this.points
        .map((point) {
          final String timestamp = point.properties.timestamp;
          final DateFormat formatter = DateFormat('dd MMM yyyy HH:mm:ss');
          final DateTime parsedTimestamp = formatter.parse(timestamp);
          final DateTime modifiedTimestamp = parsedTimestamp
            .toUtc();
            // .millisecondsSinceEpoch;

          point.properties.timestamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
              .format(modifiedTimestamp);
          return point.toApi();
        })
        .toList();
    return ApiPointBatchViewModel(points: points);
  }
}