import 'dart:io';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/domain/entities/local/last_point.dart';
import 'package:dawarich/ui/converters/batch/api_point_converter.dart';
import 'package:dawarich/ui/converters/last_point_converter.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:flutter/foundation.dart';
import 'package:dawarich/ui/models/local/last_point_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

class TrackerPageViewModel with ChangeNotifier {

  LastPointViewModel? _lastPoint;
  LastPointViewModel? get lastPoint => _lastPoint;

  int _pointInBatchCount = 0;
  int get batchPointCount => _pointInBatchCount;

  bool _dataModified = false;
  bool get dataModified => _dataModified;

  bool _isTrackingEnabled = false;
  bool _isUpdatingTracking = false;
  bool get isTrackingEnabled => _isTrackingEnabled;
  bool get isUpdatingTracking => _isUpdatingTracking;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  int _maxPointsPerBatch = 50;
  int get maxPointsPerBatch => _maxPointsPerBatch;

  int _trackingFrequency = 10; // in seconds
  int get trackingFrequency => _trackingFrequency;

  LocationAccuracy _locationAccuracy = Platform.isAndroid ? LocationAccuracy.high : LocationAccuracy.best;
  LocationAccuracy get locationAccuracy => _locationAccuracy;

  final LocalPointService _pointService;
  final TrackerPreferencesService _trackerPreferencesService;

  TrackerPageViewModel(this._pointService, this._trackerPreferencesService) {
    initialize();
  }

  Future<void> initialize() async {

    // Get last point;
    await _trackerPreferencesService.initialize();
    await getLastPoint();
    await getPointInBatchCount();

    // Retrieve settings
    await getAutomaticTrackingPreference();
    await getMaxPointsPerBatchPreference();
    await getTrackingFrequencyPreference();
    await getLocationAccuracyPreference();


  }

  void setLastPoint(LastPointViewModel? point) {

    _lastPoint = point;
    notifyListeners();
  }

  Future<void> getLastPoint() async {

    LastPoint? lastPoint =  await _pointService.getLastPoint();
    setLastPoint(lastPoint?.toViewModel());
  }


  void setPointInBatchCount(int value) {
    _pointInBatchCount = value;
    notifyListeners();
  }

  Future<void> getPointInBatchCount() async => setPointInBatchCount(await _pointService.getBatchPointsCount());

  void setDataModified(bool trueOrFalse) {
    _dataModified = trueOrFalse;
    notifyListeners();
  }

  Future<Result<void, String>> trackPoint() async {

    _setIsTracking(true);

    Result<ApiBatchPoint, String> pointResult = await _pointService.createPoint();

    if (pointResult case Ok(value: ApiBatchPoint pointEntity)) {

      ApiBatchPointViewModel point = pointEntity.toViewModel();

      String formattedTimestamp = point.properties.timestamp;
      double longitude = point.geometry.coordinates[0];
      double latitude = point.geometry.coordinates[1];

      LastPointViewModel lastPoint = LastPointViewModel(timestamp: formattedTimestamp, longitude: longitude, latitude: latitude);

      setLastPoint(lastPoint);
      await getPointInBatchCount();

      _setIsTracking(false);
      return const Ok(null);
    }

    String error = pointResult.unwrapErr();

    if (kDebugMode) {
      debugPrint("[DEBUG] Failed to create point: $error");
    }

    _setIsTracking(false);
    return Err("Failed to create point: $error Please try again later or set a higher location accuracy threshold.");
  }

  void _setIsTracking(bool trueOrFalse) {
    _isTracking = trueOrFalse;
    notifyListeners();
  }

  Future<void> setMaxPointsPerBatch(int? amount) async {
    amount ??= 50; // If null somehow, just fall back to default
    _maxPointsPerBatch = amount;
    await _trackerPreferencesService.setPointsPerBatchPreference(amount);
    notifyListeners();
  }

  Future<void> getMaxPointsPerBatchPreference() async => setMaxPointsPerBatch(await _trackerPreferencesService.getPointsPerBatchPreference());


  Future<void> toggleAutomaticTracking(bool trueOrFalse) async {
    if (!isUpdatingTracking) {
      await setAutomaticTracking(trueOrFalse);
    }
  }

  Future<void> setAutomaticTracking(bool trueOrFalse) async {
    _isUpdatingTracking = true;
    _isTrackingEnabled = trueOrFalse;
    await _trackerPreferencesService.setAutomaticTrackingPreference(trueOrFalse);

    _isUpdatingTracking = false;
    notifyListeners();
  }

  Future<void> getAutomaticTrackingPreference() async => await setAutomaticTracking(await _trackerPreferencesService.getAutomaticTrackingPreference());


  Future<void> setTrackingFrequency(int? seconds) async {
    seconds ??= 10;
    _trackingFrequency = seconds;
    await _trackerPreferencesService.setTrackingFrequencyPreference(seconds);
    notifyListeners();
  }

  Future<void> getTrackingFrequencyPreference() async => await setTrackingFrequency(await _trackerPreferencesService.getTrackingFrequencyPreference());


  Future<void> setLocationAccuracy(LocationAccuracy accuracy) async {

    _locationAccuracy = accuracy;
    await _trackerPreferencesService.setLocationAccuracyPreference(accuracy);
    _pointService.getAccuracyThreshold(locationAccuracy);
    notifyListeners();
  }

  Future<void> getLocationAccuracyPreference() async {
    await setLocationAccuracy(await _trackerPreferencesService.getLocationAccuracyPreference());
  }

  List<Map<String, dynamic>> get accuracyOptions {
    if (Platform.isIOS) {
      return [
        {"label": "Reduced", "value": LocationAccuracy.reduced},
        {"label": "Lowest", "value": LocationAccuracy.lowest},
        {"label": "Low", "value": LocationAccuracy.low},
        {"label": "Medium", "value": LocationAccuracy.medium},
        {"label": "High", "value": LocationAccuracy.high},
        {"label": "Best", "value": LocationAccuracy.best},
        {"label": "Best for Navigation", "value": LocationAccuracy.bestForNavigation},
      ];
    } else if (Platform.isAndroid) {
      return [
        {"label": "Lowest", "value": LocationAccuracy.lowest},
        {"label": "Low", "value": LocationAccuracy.low},
        {"label": "Medium", "value": LocationAccuracy.medium},
        {"label": "High", "value": LocationAccuracy.high},
      ];
    }
    return [];
  }


}