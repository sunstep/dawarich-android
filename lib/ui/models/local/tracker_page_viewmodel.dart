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
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

class TrackerPageViewModel with ChangeNotifier {

  LastPointViewModel? _lastPoint;
  LastPointViewModel? get lastPoint => _lastPoint;

  bool _hideLastPoint = true;
  bool get hideLastPoint => _hideLastPoint;

  int _pointInBatchCount = 0;
  int get batchPointCount => _pointInBatchCount;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  String _currentTrackId = "";
  String get currentTrackId => _currentTrackId;

  int _trackPointsCount = 0;
  int get trackPointsCount => _trackPointsCount;

  Duration _recordDuration = Duration();
  String get recordDuration {
    final hours = _recordDuration.inHours;
    final minutes = _recordDuration.inMinutes % 60;
    final seconds = _recordDuration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  bool _showSettings = false;
  bool get showSettings => _showSettings;

  bool _showAdvancedSettings = false;
  bool get showAdvancedSettings => _showAdvancedSettings;

  bool _isRetrievingSettings = true;
  bool get isRetrievingSettings => _isRetrievingSettings;

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

  int _minimumPointDistance = 0;
  int get minimumPointDistance => _minimumPointDistance;

  String _trackerId = "";
  String get trackerId => _trackerId;

  final TextEditingController trackerIdController = TextEditingController();


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
    await _getAutomaticTrackingPreference();
    await _getMaxPointsPerBatchPreference();
    await _getTrackingFrequencyPreference();
    await _getLocationAccuracyPreference();
    await _getMinimumPointDistancePreference();
    await _getTrackerId();

    setIsRetrievingSettings(false);
  }

  Future<void> persistPreferences() async {

    await storeAutomaticTracking();
    await storeMaxPointsPerBatch();
    await storeTrackingFrequency();
    await storeLocationAccuracy();
    await storeMinimumPointDistance();
    await storeTrackerId();
  }

  void toggleRecording() {

  }

  void toggleSettings() {
    _showSettings = !_showSettings;
    notifyListeners();
  }

  void toggleAdvancedSettings() {

    _showAdvancedSettings = !_showAdvancedSettings;
    notifyListeners();
  }

  void setLastPoint(LastPointViewModel? point) {

    _lastPoint = point;
    notifyListeners();
  }

  Future<void> getLastPoint() async {

    Option<LastPoint> lastPointResult =  await _pointService.getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      setLastPoint(lastPoint.toViewModel());
    }

  }

  void setHideLastPoint(bool trueOrFalse) {

    _hideLastPoint = trueOrFalse;
    notifyListeners();
  }


  void setPointInBatchCount(int value) {
    _pointInBatchCount = value;
    notifyListeners();
  }

  Future<void> getPointInBatchCount() async => setPointInBatchCount(await _pointService.getBatchPointsCount());

  void setIsRetrievingSettings(bool trueOrFalse) {
    _isRetrievingSettings = trueOrFalse;
    notifyListeners();
  }

  Future<Result<void, String>> trackPoint() async {

    _setIsTracking(true);
    await persistPreferences();

    Result<ApiBatchPoint, String> pointResult = await _pointService.createManualPoint();

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
    return Err("Failed to create point: $error");
  }

  void _setIsTracking(bool trueOrFalse) {
    _isTracking = trueOrFalse;
    notifyListeners();
  }

  void setMaxPointsPerBatch(int? amount) {
    amount ??= 50; // If null somehow, just fall back to default
    _maxPointsPerBatch = amount;
    notifyListeners();
  }

  Future<void> storeMaxPointsPerBatch() async {
    await _trackerPreferencesService.setPointsPerBatchPreference(_maxPointsPerBatch);
  }

  Future<void> _getMaxPointsPerBatchPreference() async => setMaxPointsPerBatch(await _trackerPreferencesService.getPointsPerBatchPreference());

  Future<void> toggleAutomaticTracking(bool trueOrFalse) async {

    if (!isUpdatingTracking) {

      _isUpdatingTracking = true;

      setAutomaticTracking(trueOrFalse);
      await storeAutomaticTracking();

      _isUpdatingTracking = false;
    }
  }

  void setAutomaticTracking(bool trueOrFalse)  {

    _isTrackingEnabled = trueOrFalse;
    notifyListeners();
  }

  Future<void> storeAutomaticTracking() async {
    await _trackerPreferencesService.setAutomaticTrackingPreference(_isTrackingEnabled);
  }

  Future<void> _getAutomaticTrackingPreference() async => setAutomaticTracking(await _trackerPreferencesService.getAutomaticTrackingPreference());


  void setTrackingFrequency(int? seconds) {
    seconds ??= 10;
    _trackingFrequency = seconds;

    notifyListeners();
  }

  Future<void> storeTrackingFrequency() async {
    await _trackerPreferencesService.setTrackingFrequencyPreference(_trackingFrequency);
  }

  Future<void> _getTrackingFrequencyPreference() async => setTrackingFrequency(await _trackerPreferencesService.getTrackingFrequencyPreference());


  void setLocationAccuracy(LocationAccuracy accuracy) {

    _locationAccuracy = accuracy;
    notifyListeners();
  }

  Future<void> storeLocationAccuracy() async {

    await _trackerPreferencesService.setLocationAccuracyPreference(_locationAccuracy);
  }

  Future<void> _getLocationAccuracyPreference() async {
    setLocationAccuracy(await _trackerPreferencesService.getLocationAccuracyPreference());
  }

  void setMinimumPointDistance(int meters) {
    _minimumPointDistance = meters;
    notifyListeners();
  }

  Future<void> storeMinimumPointDistance() async {
    await _trackerPreferencesService.setMinimumPointDistancePreference(_minimumPointDistance);
  }

  Future<void> _getMinimumPointDistancePreference() async => setMinimumPointDistance(await _trackerPreferencesService.getMinimumPointDistancePreference());

  void setTrackerId(String id) {
    _trackerId = id;
    notifyListeners();
  }

  Future<void> storeTrackerId() async {
    await _trackerPreferencesService.setTrackerId(_trackerId);
  }

  Future<void> resetTrackerId() async {

    bool reset = await _trackerPreferencesService.resetTrackerId();

    if (reset) {
      String trackerId = await _trackerPreferencesService.getTrackerId();
      setTrackerId(trackerId);
      trackerIdController.text = trackerId;
    }

  }

  Future<void> _getTrackerId() async {

    String trackerId = await _trackerPreferencesService.getTrackerId();
    setTrackerId(trackerId);
    trackerIdController.text = trackerId;
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