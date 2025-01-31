import 'package:dawarich/application/services/api_point_service.dart';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_point_batch.dart';
import 'package:dawarich/domain/entities/local/database/batch/point_batch.dart';
import 'package:dawarich/ui/converters/batch/api_point_batch_converter.dart';
import 'package:dawarich/ui/converters/batch/point_batch_converter.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_batch_viewmodel.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_viewmodel.dart';
import 'package:flutter/foundation.dart';

class BatchExplorerViewModel with ChangeNotifier {

  PointBatchViewModel _batch = PointBatchViewModel(points: []);
  PointBatchViewModel get batch => _batch;

  bool get hasPoints => batch.points.isNotEmpty;

  bool _isLoadingPoints = true;
  bool get isLoadingPoints => _isLoadingPoints;

  final LocalPointService _localPointService;
  final ApiPointService _apiPointService;

  BatchExplorerViewModel(this._localPointService, this._apiPointService) {
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

    PointBatch batch = await _localPointService.getCurrentBatch();
    PointBatchViewModel batchVm = batch.toViewModel();

    for (BatchPointViewModel point in batchVm.points) {
      point.properties.timestamp = _localPointService.formatTimestamp(point.properties.timestamp);
    }

    _setBatch(batchVm);
    _setIsLoadingPoints(false);
    notifyListeners();
  }

  Future<void> uploadBatch() async {

    ApiPointBatch apiBatch = _batch.toApi().toEntity();
    PointBatch batch = _batch.toEntity();
    bool uploaded = await _apiPointService.uploadBatch(apiBatch);

    if (uploaded) {
      bool marked = await _localPointService.markBatchAsUploaded(batch);

      if (marked) {
        await _loadBatchPoints();
      }

    }

  }

  Future<void> deletePoint(BatchPointViewModel point) async {
    await _localPointService.deletePoint(point.id);
    batch.points.remove(point);
    notifyListeners();
  }

  Future<void> clearBatch() async {
    await _localPointService.clearBatch();
    batch.points.clear();
    notifyListeners();
  }



}