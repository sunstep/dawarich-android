import 'dart:async';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

class PointAutomationService with ChangeNotifier {

  final StreamController<LocalPoint> _newPointController = StreamController.broadcast();
  Stream<LocalPoint> get newPointStream => _newPointController.stream;
  StreamSubscription<Result<Position, String>>? _stream;
  Timer? _cachedTimer;
  Timer? _gpsTimer;

  bool _isTracking = false;

  final TrackerPreferencesService _trackerPreferencesService;
  final IHardwareRepository _hardwareRepository;
  final LocalPointService _localPointService;

  PointAutomationService(this._trackerPreferencesService, this._hardwareRepository, this._localPointService);

  Future<void> startTracking() async {


    if (kDebugMode) {
      debugPrint("[PointAutomation] Starting automatic tracking...");
    }

    if (!_isTracking) {
      _isTracking = true;
      // Start all three core pieces: stream + periodic timers.
      await startCachedTimer();
      // await startStreamSubscription();
      // await startGpsTimer();
    }
  }

  /// Stop everything if user logs out, or toggles the preference off.
  Future<void> stopTracking() async {

    if (kDebugMode) {
      debugPrint("[PointAutomation] Stopping automatic tracking...");
    }

    if (_isTracking) {
      _isTracking = false;
      await stopCachedTimer();
      // await stopStreamSubscription();
      // await stopGpsTimer();
    }


  }

  /// Subscribes to live location events from the OS.
  Future<void> startStreamSubscription() async {

    if (_stream == null || _stream!.isPaused) {
      // Retrieve user’s desired accuracy and min distance from preferences
      final LocationAccuracy accuracy =
      await _trackerPreferencesService.getLocationAccuracyPreference();
      final int minimumDistance =
      await _trackerPreferencesService.getMinimumPointDistancePreference();

      // Subscribe to the position stream from our hardware repository
      final Stream<Result<Position, String>> positionStream =
      _hardwareRepository.getPositionStream(
        accuracy: accuracy,
        minimumDistance: minimumDistance,
      );

      _stream = positionStream.listen(_streamHandler);
    } else if (kDebugMode) {
      debugPrint("[DEBUG: Position stream] A position stream is already being listened to, not starting another one");
    }

  }

  /// We are notified here whenever the OS produces a new location event.
  /// We attempt to store that position using LocalPointService.
  Future<void> _streamHandler(Result<Position, String> result) async {
    if (result case Ok(value: Position position)) {
      final Result<LocalPoint, String> storeResult = await _localPointService.createAndStorePoint(position);
      if (storeResult case Ok(value: LocalPoint point)) {
        _newPointController.add(point); // Publish the new point.
      } else if (storeResult case Err(value: String err)) {
        debugPrint("[PointAutomation] Stream location not stored: $err");
      }
    } else if (result case Err(value: String error)) {
      debugPrint("[PointAutomation] Location stream error: $error");
    }
  }

  Future<void> stopStreamSubscription() async {
    await _stream?.cancel();
    _stream = null;
  }

  /// A small timer that periodically tries to store the phone’s “cached” position.
  /// If it succeeds in storing a brand-new cached point, we reset the GPS timer
  /// to avoid extra fetches for a bit.
  Future<void> startCachedTimer() async {

    if (_cachedTimer == null || !_cachedTimer!.isActive) {
      _cachedTimer = Timer.periodic(const Duration(seconds: 5), _cachedTimerHandler);

    } else if (kDebugMode){
      debugPrint("[PointAutomation] Cached timer is already running; not starting a new one.");
    }

  }

  Future<void> _cachedTimerHandler(Timer timer) async {

    if (kDebugMode) {
      debugPrint("[DEBUG] Creating point from cache");
    }

    if (_isTracking) {
      final Result<LocalPoint, String> optionPoint = await _localPointService.createPointFromCache();

      if (optionPoint case Ok(value: LocalPoint point)) {
        // We actually got a new point from the phone’s cache, so reset the GPS timer.
        // This basically says “we got a point anyway, so hold off on forcing another one too soon.”
        _newPointController.add(point);
        await _restartGpsTimer();

        if (kDebugMode) {
          debugPrint("[DEBUG: automatic point tracking] Cached point found! Storing it...");
        }
      } else if (kDebugMode){
        debugPrint("[DEBUG] Cached point was rejected");
      }
    }

  }

  Future<void> stopCachedTimer() async {

    if (kDebugMode) {
      debugPrint("[DEBUG] Stopping cached points timer");
    }

    _cachedTimer?.cancel();
    _cachedTimer = null;
  }

  /// A timer that forces a brand new location fetch from Geolocator every N seconds
  /// (based on user’s preference).
  Future<void> startGpsTimer() async {

    if (_gpsTimer == null || !_gpsTimer!.isActive) {
      final int trackingFrequency =
      await _trackerPreferencesService.getTrackingFrequencyPreference();
      _gpsTimer = Timer.periodic(
        Duration(seconds: trackingFrequency),
        _gpsTimerHandler,
      );
    } else if (kDebugMode) {
      debugPrint("[DEBUG: GPS Timer] A GPS timer is already active, not starting another one.");
    }


  }

  /// Forces a new position fetch by calling localPointService.createNewPoint().
  Future<void> _gpsTimerHandler(Timer timer) async {

    if (_isTracking) {
      final result = await _localPointService.createPointFromGps();

      if (result case Ok(value: LocalPoint point)) {
        _newPointController.add(point);
      } else if (result case Err(value: String err)) {
        debugPrint("[PointAutomation] Forced GPS point not stored: $err");
      }
    }

  }

  Future<void> stopGpsTimer() async {
    _gpsTimer?.cancel();
    _gpsTimer = null;
  }

  /// Cancels and restarts the GPS timer. Called when we’ve just stored a cached point
  /// so we don’t spam the device with forced GPS calls too soon.
  Future<void> _restartGpsTimer() async {
    await stopGpsTimer();
    await startGpsTimer();
  }




}