import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_batch.dart';
import 'package:dawarich/ui/converters/batch/overland/overland_point_converter.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_batch_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_viewmodel.dart';

extension OverlandBatchConverter on OverlandPointBatch {

  OverlandPointBatchViewModel toViewModel() {
    List<OverlandPointViewModel> points = this.points
        .map((point) => point.toViewModel())
        .toList();
    return OverlandPointBatchViewModel(points: points);
  }
}



extension OverlandBatchDtoConverter on OverlandPointBatchViewModel {

  OverlandPointBatch toEntity() {
    List<OverlandPoint> points = this.points
        .map((pointDto) => pointDto.toEntity())
        .toList();
    return OverlandPointBatch(points: points);
  }
}

