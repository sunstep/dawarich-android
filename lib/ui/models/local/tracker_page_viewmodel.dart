import 'dart:async';
import 'dart:io';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/application/services/point_automation_service.dart';
import 'package:dawarich/application/services/system_settings_service.dart';
import 'package:dawarich/application/services/track_service.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/domain/entities/local/last_point.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point.dart';
import 'package:dawarich/domain/entities/track/track.dart';
import 'package:dawarich/ui/converters/batch/local/local_point_converter.dart';
import 'package:dawarich/ui/converters/last_point_converter.dart';
import 'package:dawarich/ui/converters/track_converter.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_viewmodel.dart';
import 'package:dawarich/ui/models/track/track_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:dawarich/ui/models/local/last_point_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

class TrackerPageViewModel extends ChangeNotifier {

  LastPointViewModel? _lastPoint;
  LastPointViewModel? get lastPoint => _lastPoint;

  bool _hideLastPoint = false;
  bool get hideLastPoint => _hideLastPoint;

  int _pointInBatchCount = 0;
  int get batchPointCount => _pointInBatchCount;

  TrackViewModel? _currentTrack;
  TrackViewModel? get currentTrack => _currentTrack;
  void setCurrentTrack(TrackViewModel track) {
    _currentTrack = track;
    notifyListeners();
  }

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  void setIsRecording(bool trueOrFalse) {
    _isRecording = trueOrFalse;
    notifyListeners();
  }

  String _currentTrackId = "";
  String get currentTrackId => _currentTrackId;

  void setCurrentTrackId(String id) {
    _currentTrackId = id;
    notifyListeners();
  }

  int _trackPointCount = 0;
  int get trackPointCount => _trackPointCount;

  void setTrackPointCount(int count) {
    _trackPointCount = count;
    notifyListeners();
  }

  // Duration _recordDuration = Duration();
  // String get recordDuration {
  //   final hours = _recordDuration.inHours;
  //   final minutes = _recordDuration.inMinutes % 60;
  //   final seconds = _recordDuration.inSeconds % 60;
  //   return '${hours.toString().padLeft(2, '0')}:'
  //       '${minutes.toString().padLeft(2, '0')}:'
  //       '${seconds.toString().padLeft(2, '0')}';
  // }

  int _currentPage = 0;
  int get currentPage => _currentPage;

  // void previousPage() {
  //   if (_currentPage > 0) {
  //     _currentPage--;
  //   } else {
  //     _currentPage = 2;
  //   }
  //
  //   notifyListeners();
  // }

  void setCurrentPage(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < 2) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    notifyListeners();
  }

  String get pageTitle {
    switch (_currentPage) {
      case 0: return "Track Recording";
      case 1: return "Basic Settings";
      case 2: return "Advanced Settings";
      default: return "";
    }
  }

  String get toggleButtonText {
    switch (_currentPage) {
      case 0: return "Show Basic Settings";
      case 1: return "Show Advanced Settings";
      case 2: return "Show Recording";
      default: return "";
    }
  }

  bool _isRetrievingSettings = true;
  bool get isRetrievingSettings => _isRetrievingSettings;

  bool _isTrackingAutomatically = false;
  bool _isUpdatingTracking = false;
  bool get isTrackingAutomatically => _isTrackingAutomatically;
  bool get isUpdatingTracking => _isUpdatingTracking;

  final _settingsPromptController = StreamController<void>.broadcast();
  Stream<void> get onSystemSettingsPrompt => _settingsPromptController.stream;

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

  final TextEditingController deviceIdController = TextEditingController();


  final LocalPointService _pointService;
  // final BackgroundTrackingService _backgroundTrackingService = BackgroundTrackingService();
  final PointAutomationService _pointAutomationService;
  final TrackerPreferencesService _trackerPreferencesService;
  final TrackService _trackService;
  final SystemSettingsService _systemSettingsService;

  TrackerPageViewModel(this._pointService, this._pointAutomationService, this._trackService, this._trackerPreferencesService, this._systemSettingsService) {
    initialize();
  }

  Future<void> initialize() async {

    _pointAutomationService.newPointStream.listen((LocalPoint point) async {

      final LocalPointViewModel pointViewModel = point.toViewModel();
      final LastPointViewModel lastPoint = LastPointViewModel.fromPoint(pointViewModel);
      setLastPoint(lastPoint);
      await getPointInBatchCount();
      notifyListeners();

      if (kDebugMode) {
        debugPrint("[DEBUG] Point created automatically");
      }
    });

    // Get last point;
    await getLastPoint();
    await getPointInBatchCount();

    // Retrieve settings
    await _getAutomaticTrackingPreference();
    await _getMaxPointsPerBatchPreference();
    await _getTrackingFrequencyPreference();
    await _getLocationAccuracyPreference();
    await _getMinimumPointDistancePreference();
    await _getTrackerId();
    await _getTrackRecordingStatus();

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

  Future<void> _getTrackRecordingStatus() async {

    Option<Track> trackResult = await _trackService.getActiveTrack();

    if (trackResult case Some(value: Track track)) {
      TrackViewModel trackVm = track.toViewModel();
      setCurrentTrack(trackVm);
      setIsRecording(true);
    }
  }

  void toggleRecording() async {

    if (isRecording) {
      _trackService.stopTracking();

    } else {
      Track track = await _trackService.startTracking();
      TrackViewModel trackVm = track.toViewModel();
      setCurrentTrackId(trackVm.trackId);
    }

    setIsRecording(!isRecording);

  }

  void setLastPoint(LastPointViewModel? point) {

    _lastPoint = point;
    notifyListeners();
  }

  Future<void> getLastPoint() async {

    Option<LastPoint> lastPointResult =  await _pointService.getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {

      LastPointViewModel lastPointViewModel = lastPoint.toViewModel();
      setLastPoint(lastPointViewModel);
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

  Future<Result<(), String>> trackPoint() async {

    _setIsTracking(true);
    await persistPreferences();

    Result<LocalPoint, String> pointResult = await _pointService.createPointFromGps();

    if (pointResult case Ok(value: LocalPoint pointEntity)) {

      LocalPointViewModel point = pointEntity.toViewModel();

      String timestamp = point.properties.timestamp;
      double longitude = point.geometry.coordinates[0];
      double latitude = point.geometry.coordinates[1];

      LastPointViewModel lastPoint = LastPointViewModel(rawTimestamp: timestamp, longitude: longitude, latitude: latitude);

      setLastPoint(lastPoint);
      await getPointInBatchCount();

      _setIsTracking(false);
      return const Ok(());
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

  void toggleAutomaticTracking(bool enable) {
    if (_isUpdatingTracking) return;

    _isUpdatingTracking = true;

    _isTrackingAutomatically = enable;
    notifyListeners();

    _applyAutomaticTracking(enable);
  }

  Future<void> _applyAutomaticTracking(bool enable) async {
    try {
      if (enable) {
        await _pointAutomationService.startTracking();

        final needsFix = await _systemSettingsService.needsSystemSettingsFix();
        if (needsFix) {
          _settingsPromptController.add(null);
        }
      } else {
        await _pointAutomationService.stopTracking();
      }

      await _trackerPreferencesService.setAutomaticTrackingPreference(enable);
    } catch (e) {
      _isTrackingAutomatically = !enable;
      debugPrint('Error toggling automatic tracking: $e');
    } finally {
      _isUpdatingTracking = false;
      notifyListeners();
    }
  }

  Future<void> openSystemSettings() async {

    await _systemSettingsService.openSystemSettings();
  }

  Future<void> storeAutomaticTracking() async {
    await _trackerPreferencesService.setAutomaticTrackingPreference(_isTrackingAutomatically);
  }

  Future<void> _getAutomaticTrackingPreference() async => _applyAutomaticTracking(await _trackerPreferencesService.getAutomaticTrackingPreference());


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
      deviceIdController.text = trackerId;
    }

  }

  Future<void> _getTrackerId() async {

    String trackerId = await _trackerPreferencesService.getTrackerId();
    setTrackerId(trackerId);
    deviceIdController.text = trackerId;
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

  @override
  void dispose() {
    _settingsPromptController.close();
    super.dispose();
  }

}