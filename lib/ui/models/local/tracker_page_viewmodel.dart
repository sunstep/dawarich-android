import 'dart:io';

import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dawarich/ui/models/local/last_point.dart';
import 'package:geolocator/geolocator.dart';

class TrackerPageViewModel with ChangeNotifier {

  LastPoint? _lastPoint;
  LastPoint? get lastPoint => _lastPoint;

  int _pointInBatchCount = 0;
  int get batchPointCount => _pointInBatchCount;

  bool _isTrackingEnabled = false;
  bool _isUpdatingTracking = false;
  bool get isTrackingEnabled => _isTrackingEnabled;
  bool get isUpdatingTracking => _isUpdatingTracking;


  int _maxPointsPerBatch = 50;
  int get maxPointsPerBatch => _maxPointsPerBatch;

  int _trackingFrequency = 10; // in seconds
  int get trackingFrequency => _trackingFrequency;

  int _desiredAccuracyMeters = 5; // in meters
  // int get desiredAccuracyMeters => _desiredAccuracyMeters;

  LocationAccuracy _locationAccuracy = Platform.isAndroid ? LocationAccuracy.high : LocationAccuracy.best;
  LocationAccuracy get locationAccuracy => _locationAccuracy;

  final LocalPointService _pointService;
  final TrackerPreferencesService _trackerPreferencesService;

  TrackerPageViewModel(this._pointService, this._trackerPreferencesService);

  Future<void> initialize() async {
    // Get last point;
    setLastPoint(await _pointService.getLastPoint());
    setPointInBatchCount(await _pointService.getBatchPointsCount());

    // Retrieve settings
    setAutomaticTracking(await _trackerPreferencesService.getAutomaticTrackingPreference());
    setMaxPointsPerBatch(await _trackerPreferencesService.getPointsPerBatchPreference());
    setTrackingFrequency(await _trackerPreferencesService.getTrackingFrequencyPreference());
    setLocationAccuracy(await _trackerPreferencesService.getLocationAccuracyPreference());
  }

  void setLastPoint(LastPoint? point) {
    _lastPoint = point;
    notifyListeners();
  }

  void setPointInBatchCount(int value) {
    _pointInBatchCount = value;
    notifyListeners();
  }

  // Future<void> trackPoint() async {
  //
  //   await _pointService.createPoint();
  // }

  Future<void> setMaxPointsPerBatch(int? amount) async {
    amount ??= 50; // If null somehow, just fall back to default
    _maxPointsPerBatch = amount;
    await _trackerPreferencesService.setPointsPerBatchPreference(amount);
    notifyListeners();
  }

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

  Future<void> setTrackingFrequency(int? seconds) async {
    seconds ??= 10;
    _trackingFrequency = seconds;
    await _trackerPreferencesService.setTrackingFrequencyPreference(seconds);
    notifyListeners();
  }

  Future<void> setLocationAccuracy(LocationAccuracy accuracy) async {

    _locationAccuracy = accuracy;
    await _trackerPreferencesService.setLocationAccuracyPreference(accuracy);
    _mapLocationAccuracy();
    notifyListeners();
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

  void _mapLocationAccuracy() {

  }





}