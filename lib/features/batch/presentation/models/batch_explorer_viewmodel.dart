import 'package:dawarich/core/application/services/api_point_service.dart';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_batch.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_properties.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/batch/presentation/models/local_point_viewmodel.dart';
import 'package:dawarich/features/batch/presentation/converters/local_point_converter.dart';
import 'package:flutter/foundation.dart';

class BatchExplorerViewModel extends ChangeNotifier {

  List<LocalPointViewModel> _batch = [];
  List<LocalPointViewModel> get batch => _batch;

  bool get hasPoints => batch.isNotEmpty;

  bool _isLoadingPoints = true;
  bool get isLoadingPoints => _isLoadingPoints;

  final LocalPointService _localPointService;
  final ApiPointService _apiPointService;

  BatchExplorerViewModel(this._localPointService, this._apiPointService) {
    _initialize();
  }

  void _setBatch(List<LocalPointViewModel> batch) {
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
    List<LocalPoint> batch = await _localPointService.getCurrentBatch();
    List<LocalPointViewModel> batchVm = batch.map((point) =>
        point.toViewModel()).toList();

    _setBatch(batchVm);
    _setIsLoadingPoints(false);
    notifyListeners();
  }

  Future<void> uploadBatch() async {

    List<DawarichPoint> pointsToUpload = _batch.map((localPoint) {
      return DawarichPoint(
        type: localPoint.type,
        geometry: DawarichPointGeometry(
            type: localPoint.geometry.type,
            coordinates: localPoint.geometry.coordinates),
        properties: DawarichPointProperties(
          batteryState: localPoint.properties.batteryState,
          batteryLevel: localPoint.properties.batteryLevel,
          wifi: localPoint.properties.wifi,
          timestamp: localPoint.properties.timestamp,
          horizontalAccuracy: localPoint.properties.horizontalAccuracy,
          verticalAccuracy: localPoint.properties.verticalAccuracy,
          altitude: localPoint.properties.altitude,
          speed: localPoint.properties.speed,
          speedAccuracy: localPoint.properties.speedAccuracy,
          course: localPoint.properties.course,
          courseAccuracy: localPoint.properties.courseAccuracy,
          trackId: localPoint.properties.trackId,
          deviceId: localPoint.properties.deviceId,
        ),
      );
    }).toList();

    DawarichPointBatch apiBatch = DawarichPointBatch(points: pointsToUpload);

    bool uploaded = await _apiPointService.uploadBatch(apiBatch);

    if (uploaded) {
      List<LocalPoint> batchD = _batch.map((point) =>
          point.toDomain()).toList();
      bool marked =
          await _localPointService.markBatchAsUploaded(batchD);

      if (marked) {
        await _loadBatchPoints();
      }
    }
  }

  Future<void> deletePoint(LocalPointViewModel point) async {
    await _localPointService.deletePoint(point.id);
    batch.remove(point);
    notifyListeners();
  }

  Future<void> clearBatch() async {
    await _localPointService.clearBatch();
    batch.clear();
    notifyListeners();
  }
}
