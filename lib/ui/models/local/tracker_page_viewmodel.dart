import 'dart:io';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/models/local/last_point.dart';
import 'package:geolocator/geolocator.dart';

class TrackerPageViewModel with ChangeNotifier {

  LastPoint? _lastPoint;
  LastPoint? get lastPoint => _lastPoint;

  int _pointInBatchCount = 0;
  int get batchPointCount => _pointInBatchCount;

  bool _dataModified = false;
  bool get dataModified => _dataModified;

  bool _isTrackingEnabled = false;
  bool _isUpdatingTracking = false;
  bool get isTrackingEnabled => _isTrackingEnabled;
  bool get isUpdatingTracking => _isUpdatingTracking;

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
    await getLastPoint();
    await getPointInBatchCount();

    // Retrieve settings
    await getAutomaticTrackingPreference();
    await getMaxPointsPerBatchPreference();
    await getTrackingFrequencyPreference();
    await getLocationAccuracyPreference();


  }

  void setLastPoint(LastPoint? point) {

    _lastPoint = point;
    notifyListeners();
  }

  Future<void> getLastPoint() async => setLastPoint(await _pointService.getLastPoint());


  void setPointInBatchCount(int value) {
    _pointInBatchCount = value;
    notifyListeners();
  }

  Future<void> getPointInBatchCount() async => setPointInBatchCount(await _pointService.getBatchPointsCount());

  void setDataModified(bool trueOrFalse) {
    _dataModified = trueOrFalse;
    notifyListeners();
  }

  Future<void> trackPoint() async {

    Point point = await _pointService.createPoint();

    String formattedTimestamp = _pointService.formatTimestamp(point.properties.timestamp);
    double longitude = point.geometry.coordinates[0];
    double latitude = point.geometry.coordinates[1];

    LastPoint lastPoint = LastPoint(timestamp: formattedTimestamp, longitude: longitude, latitude: latitude);

    setLastPoint(lastPoint);
    await getPointInBatchCount();
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