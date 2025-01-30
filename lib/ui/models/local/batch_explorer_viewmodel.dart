import 'package:dawarich/application/converters/batch/point_batch_converter.dart';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_batch.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_batch_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_viewmodel.dart';
import 'package:flutter/foundation.dart';

class BatchExplorerViewModel with ChangeNotifier {

  PointBatchViewModel _batch = PointBatchViewModel(points: []);
  PointBatchViewModel get batch => _batch;

  bool get hasPoints => batch.points.isNotEmpty;

  bool _isLoadingPoints = true;
  bool get isLoadingPoints => _isLoadingPoints;

  final LocalPointService _pointService;

  BatchExplorerViewModel(this._pointService) {
    _initialize();
  }

  void _setBatch(PointBatchViewModel batch) {
    _batch = batch;
    notifyListeners();
  }

  void _setIsLoadingPoints(bool trueOrFalse) {
    _isLoadingPoints = trueOrFalse;
    notifyListeners();
  }

  Future<void> _initialize() async {
    await _loadBatchPoints();
  }


  Future<void> _loadBatchPoints() async {

    PointBatch batch = await _pointService.getCurrentBatch();
    PointBatchViewModel batchVm = batch.toViewModel();

    for (PointViewModel point in batchVm.points) {
      point.properties.timestamp = _pointService.formatTimestamp(point.properties.timestamp);
    }

    _setBatch(batchVm);
    _setIsLoadingPoints(false);
    notifyListeners();
  }

  Future<void> deletePoint(PointViewModel point) async {
    await _pointService.deletePoint(point.id);
    batch.points.remove(point);
    notifyListeners();
  }

  Future<void> clearBatch() async {
    await _pointService.clearBatch();
    batch.points.clear();
    notifyListeners();
  }



}