import 'package:dawarich/application/services/api_point_service.dart';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_batch.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_geometry.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_properties.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_batch.dart';
import 'package:dawarich/ui/converters/batch/local/local_point_batch_converter.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_batch_viewmodel.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_viewmodel.dart';
import 'package:flutter/foundation.dart';

class BatchExplorerViewModel with ChangeNotifier {

  LocalPointBatchViewModel _batch = LocalPointBatchViewModel(points: []);
  LocalPointBatchViewModel get batch => _batch;

  bool get hasPoints => batch.points.isNotEmpty;

  bool _isLoadingPoints = true;
  bool get isLoadingPoints => _isLoadingPoints;

  final LocalPointService _localPointService;
  final ApiPointService _apiPointService;

  BatchExplorerViewModel(this._localPointService, this._apiPointService) {
    _initialize();
  }

  void _setBatch(LocalPointBatchViewModel batch) {
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

    LocalPointBatch batch = await _localPointService.getCurrentBatch();
    LocalPointBatchViewModel batchVm = batch.toViewModel();


    _setBatch(batchVm);
    _setIsLoadingPoints(false);
    notifyListeners();
  }

  Future<void> uploadBatch() async {


    List<DawarichPoint> pointsToUpload = _batch.points.map((localPoint) {
      return DawarichPoint(
        type: localPoint.type,
        geometry: DawarichPointGeometry(
          type: localPoint.geometry.type,
          coordinates: localPoint.geometry.coordinates
        ),
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
      bool marked = await _localPointService.markBatchAsUploaded(_batch.toEntity());

      if (marked) {
        await _loadBatchPoints();
      }

    }

  }

  Future<void> deletePoint(LocalPointViewModel point) async {
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