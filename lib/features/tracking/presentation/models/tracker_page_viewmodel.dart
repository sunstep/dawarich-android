import 'dart:async';
import 'dart:io';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/features/tracking/application/services/background_tracking_service.dart';
import 'package:dawarich/features/tracking/application/services/point_automation_service.dart';
import 'package:dawarich/features/tracking/application/services/system_settings_service.dart';
import 'package:dawarich/features/tracking/application/services/track_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_settings_service.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';
import 'package:dawarich/features/batch/presentation/converters/local_point_converter.dart';
import 'package:dawarich/features/tracking/presentation/converters/last_point_converter.dart';
import 'package:dawarich/features/tracking/presentation/converters/track_converter.dart';
import 'package:dawarich/features/batch/presentation/models/local_point_viewmodel.dart';
import 'package:dawarich/features/tracking/presentation/models/track_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:dawarich/features/tracking/presentation/models/last_point_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
import 'package:permission_handler/permission_handler.dart';

final class TrackerPageViewModel extends ChangeNotifier {

  LastPointViewModel? _lastPoint;
  LastPointViewModel? get lastPoint => _lastPoint;

  int _batchPointCount = 0;
  int get batchPointCount => _batchPointCount;

  bool _hideLastPoint = false;
  bool get hideLastPoint => _hideLastPoint;

  StreamSubscription<Option<LastPoint>>? _lastPointSub;
  StreamSubscription<int>? _batchCountSub;

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
      case 0:
        return "Track Recording";
      case 1:
        return "Basic Settings";
      case 2:
        return "Advanced Settings";
      default:
        return "";
    }
  }

  String get toggleButtonText {
    switch (_currentPage) {
      case 0:
        return "Show Basic Settings";
      case 1:
        return "Show Advanced Settings";
      case 2:
        return "Show Recording";
      default:
        return "";
    }
  }

  bool _isRetrievingSettings = true;
  bool get isRetrievingSettings => _isRetrievingSettings;

  bool _isTrackingAutomatically = false;
  bool _isUpdatingTracking = false;
  bool get isTrackingAutomatically => _isTrackingAutomatically;
  bool get isUpdatingTracking => _isUpdatingTracking;

  final _consentPromptController = StreamController<String>.broadcast();
  Stream<String> get onConsentPrompt => _consentPromptController.stream;
  Completer<bool>? _consentResponseCompleter;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  int _maxPointsPerBatch = 50;
  int get maxPointsPerBatch => _maxPointsPerBatch;

  int _trackingFrequency = 10; // in seconds
  int get trackingFrequency => _trackingFrequency;

  LocationAccuracy _locationAccuracy =
      Platform.isAndroid ? LocationAccuracy.high : LocationAccuracy.best;
  LocationAccuracy get locationAccuracy => _locationAccuracy;

  int _minimumPointDistance = 0;
  int get minimumPointDistance => _minimumPointDistance;

  String _deviceId = "";
  String get deviceId => _deviceId;

  final TextEditingController deviceIdController = TextEditingController();

  final LocalPointService _pointService;
  final PointAutomationService _pointAutomationService;
  final TrackerSettingsService _trackerPreferencesService;
  final TrackService _trackService;
  final SystemSettingsService _systemSettingsService;

  TrackerPageViewModel(
      this._pointService,
      this._pointAutomationService,
      this._trackService,
      this._trackerPreferencesService,
      this._systemSettingsService);

  Future<void> initialize() async {

    await BackgroundTrackingService.initializeListeners();

    Stream<Option<LastPoint>> lastPointStream = await _pointService
        .watchLastPoint();

    _lastPointSub = lastPointStream.listen((option) {

      if (option case Some(value: LastPoint lastPoint)) {

        if (kDebugMode) {
          debugPrint("[DEBUG] Last point stream received: ${option.unwrap()}");
        }

        LastPointViewModel lastPointViewModel = lastPoint.toViewModel();
        setLastPoint(lastPointViewModel);
      } else {
        setLastPoint(null);
      }
    });

    Stream<int> batchCountStream = await _pointService.watchBatchPointsCount();

    _batchCountSub = batchCountStream.listen((count) {
      if (kDebugMode) {
        debugPrint("[DEBUG] Batch count stream received: $count");
      }
      setBatchPointCount(count);
    });

    // Retrieve settings
    await _getAutomaticTrackingPreference();
    await _getMaxPointsPerBatchPreference();
    await _getTrackingFrequencyPreference();
    await _getLocationAccuracyPreference();
    await _getMinimumPointDistancePreference();
    await _getDeviceId();
    await _getTrackRecordingStatus();


    setIsRetrievingSettings(false);
  }

  Future<void> persistPreferences() async {
    await _trackerPreferencesService.persistSettings();
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
      setCurrentTrack(trackVm);
    }

    setIsRecording(!isRecording);
  }

  void setLastPoint(LastPointViewModel? point) {
    _lastPoint = point;
    notifyListeners();
  }

  Future<void> getLastPoint() async {
    Option<LastPoint> lastPointResult = await _pointService.getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      LastPointViewModel lastPointViewModel = lastPoint.toViewModel();
      setLastPoint(lastPointViewModel);
    }
  }

  void setHideLastPoint(bool trueOrFalse) {
    _hideLastPoint = trueOrFalse;
    notifyListeners();
  }

  void setBatchPointCount(int value) {
    _batchPointCount = value;
    notifyListeners();
  }

  Future<void> getPointInBatchCount() async =>
      setBatchPointCount(await _pointService.getBatchPointsCount());

  void setIsRetrievingSettings(bool trueOrFalse) {
    _isRetrievingSettings = trueOrFalse;
    notifyListeners();
  }

  Future<Result<(), String>> trackPoint() async {
    setIsTracking(true);
    await persistPreferences();

    Result<LocalPoint, String> pointResult =
        await _pointService.createPointFromGps();

    if (pointResult case Ok(value: LocalPoint pointEntity)) {
      LocalPointViewModel point = pointEntity.toViewModel();

      String timestamp = point.properties.timestamp;
      double longitude = point.geometry.longitude;
      double latitude = point.geometry.latitude;

      LastPointViewModel lastPoint = LastPointViewModel(
          rawTimestamp: timestamp, longitude: longitude, latitude: latitude);

      setLastPoint(lastPoint);
      await getPointInBatchCount();

      setIsTracking(false);
      return const Ok(());
    }

    String error = pointResult.unwrapErr();

    if (kDebugMode) {
      debugPrint("[DEBUG] Failed to create point: $error");
    }

    setIsTracking(false);
    return Err("Failed to create point: $error");
  }

  void setIsTracking(bool trueOrFalse) {
    _isTracking = trueOrFalse;
    notifyListeners();
  }

  Future<void> setMaxPointsPerBatch(int? amount) async {
    amount ??= 50; // If null somehow, just fall back to default
    _maxPointsPerBatch = amount;
    notifyListeners();
    await _trackerPreferencesService
        .setPointsPerBatchSetting(_maxPointsPerBatch);
  }

  Future<void> _getMaxPointsPerBatchPreference() async => setMaxPointsPerBatch(
      await _trackerPreferencesService.getPointsPerBatchSetting());

  Future<bool> requestConsentFromUser(String message) {
    _consentResponseCompleter = Completer<bool>();
    _consentPromptController.add(message);
    return _consentResponseCompleter!.future;
  }

  void handleConsentResponse(bool accepted) {
    _consentResponseCompleter?.complete(accepted);
    _consentResponseCompleter = null;
  }

  Future<bool> _requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  Future<bool> _shouldShowConsentDialog() async {
    final location = await Permission.locationAlways.status;
    final notifications = await Permission.notification.status;

    final hasLocation = location.isGranted;
    final hasNotifications = notifications.isGranted;

    final batteryExcluded = !await _systemSettingsService.needsSystemSettingsFix();

    return !hasLocation || !hasNotifications || !batteryExcluded;
  }

  void setAutomaticTracking(bool enable) {
    _isTrackingAutomatically = enable;
    notifyListeners();
  }

  void setIsUpdatingTracking(bool trueOrFalse) {
    _isUpdatingTracking = trueOrFalse;
    notifyListeners();
  }

  Future<Result<(), String>> toggleAutomaticTracking(bool enable) async {

    if (_isUpdatingTracking) {
      return Err("Tracking update already in progress.");
    }

    setIsUpdatingTracking(true);
    setAutomaticTracking(enable);

    await _trackerPreferencesService.setAutomaticTrackingSetting(enable);

    if (enable) {
      if (await _shouldShowConsentDialog()) {
        final confirmed = await requestConsentFromUser(
            'To enable automatic background tracking, Dawarich needs your permission.\n\n'
                'It will request background location access, notification permission, and system exclusions.'
        );

        if (!confirmed) {
          setAutomaticTracking(false);
          await _trackerPreferencesService.setAutomaticTrackingSetting(false);
          setIsUpdatingTracking(false);
          return Err("Permission setup cancelled by user.");
        }
      }

      final permissionResult = await _requestTrackingPermissions();
      if (permissionResult case Err(value: final message)) {
        setAutomaticTracking(false);
        await _trackerPreferencesService.setAutomaticTrackingSetting(false);
        setIsUpdatingTracking(false);
        return Err(message);
      }

      final notificationGranted = await _requestNotificationPermission();
      if (!notificationGranted) {
        setAutomaticTracking(false);
        await _trackerPreferencesService.setAutomaticTrackingSetting(false);
        setIsUpdatingTracking(false);
        return Err("Notification permission is required.");
      }

      final serviceResult = await BackgroundTrackingService.start();
      debugPrint("[TrackerPageViewModel] Background start result: $serviceResult");

      final needsFix = await _systemSettingsService.needsSystemSettingsFix();

      if (serviceResult case Err(value: final message)) {
        if (needsFix) {
          _consentPromptController.add(
              'Some system settings still need your help to enable reliable background tracking.\n\n'
                  'Please check location permission, battery optimization, and notification settings.'
          );
        }

        setAutomaticTracking(false);
        await _trackerPreferencesService.setAutomaticTrackingSetting(false);
        setIsUpdatingTracking(false);

        return Err("Failed to start background service: $message");
      }

      FlutterBackgroundService().invoke('proceed');

    } else {
      BackgroundTrackingService.stop();
    }

    setIsUpdatingTracking(false);
    return Ok(());
  }

  Future<Result<(), String>> _requestTrackingPermissions() async {

    final locationStatus = await Permission.locationAlways.request();

    if (locationStatus.isPermanentlyDenied) {
      return Err("Permission is permanently denied. Please enable it manually in system settings.");
    }

    if (!locationStatus.isGranted) {
      return Err("Location permission 'Always' is required for background tracking.");
    }

    await openSystemSettings();

    return const Ok(());
  }



  Future<void> openSystemSettings() async {
    await _systemSettingsService.openSystemSettings();
  }

  Future<void> _getAutomaticTrackingPreference() async {
    final bool shouldTrackAutomatically =
        await _trackerPreferencesService.getAutomaticTrackingSetting();
    await toggleAutomaticTracking(shouldTrackAutomatically);
  }

  Future<void> setTrackingFrequency(int? seconds) async {
    seconds ??= 10;
    _trackingFrequency = seconds;
    await _trackerPreferencesService
        .setTrackingFrequencySetting(_trackingFrequency);


    notifyListeners();
  }


  Future<void> _getTrackingFrequencyPreference() async => setTrackingFrequency(
      await _trackerPreferencesService.getTrackingFrequencySetting());

  Future<void> setLocationAccuracy(LocationAccuracy accuracy) async {
    _locationAccuracy = accuracy;
    await _trackerPreferencesService
        .setLocationAccuracySetting(_locationAccuracy);
    notifyListeners();
  }


  Future<void> _getLocationAccuracyPreference() async {
    setLocationAccuracy(
        await _trackerPreferencesService.getLocationAccuracySetting());
  }

  Future<void> setMinimumPointDistance(int meters) async {
    _minimumPointDistance = meters;
    await _trackerPreferencesService
        .setMinimumPointDistanceSetting(_minimumPointDistance);

    notifyListeners();
  }

  Future<void> _getMinimumPointDistancePreference() async =>
      setMinimumPointDistance(
          await _trackerPreferencesService.getMinimumPointDistanceSetting());

  Future<void> setDeviceId(String id) async {
    _deviceId = id;
    await _trackerPreferencesService.setDeviceId(_deviceId);
    notifyListeners();
  }

  Future<void> resetDeviceId() async {
    bool isReset = await _trackerPreferencesService.resetDeviceId();

    if (isReset) {
      String deviceId = await _trackerPreferencesService.getDeviceId();
      setDeviceId(deviceId);
      deviceIdController.text = deviceId;
    }
  }

  Future<void> _getDeviceId() async {
    String trackerId = await _trackerPreferencesService.getDeviceId();
    setDeviceId(trackerId);
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
        {
          "label": "Best for Navigation",
          "value": LocationAccuracy.bestForNavigation
        },
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

    if (kDebugMode) {
      debugPrint("[TrackerPageViewModel] Disposing viewmodel...");
    }

    _lastPointSub?.cancel();
    _batchCountSub?.cancel();
    _consentPromptController.close();
    deviceIdController.dispose();
    super.dispose();
  }
}
