import 'dart:async';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_preferences_service.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:option_result/option_result.dart';

final class PointAutomationService with ChangeNotifier {

  Timer? _cachedTimer;
  Timer? _gpsTimer;

  bool _isTracking = false;
  bool _isHandlingNewPoint = false;

  int _gpsTimerFrequency = 0;

  final ServiceInstance? _serviceInstance;
  final TrackerPreferencesService _trackerPreferencesService;
  final LocalPointService _localPointService;

  PointAutomationService(this._trackerPreferencesService,
      this._localPointService, [this._serviceInstance]);

  Future<void> startTracking() async {
    if (kDebugMode) {
      debugPrint("[PointAutomation] Starting automatic tracking...");
    }

    if (!_isTracking) {
      _isTracking = true;
      // Start all three core pieces: stream + periodic timers.
      await startGpsTimer();
      // await startCachedTimer();

    }
  }

  /// Stop everything if user logs out, or toggles the preference off.
  Future<void> stopTracking() async {

    if (_isTracking) {
      _isTracking = false;
      debugPrint("[PointAutomation] Tracking stopped");
    }
  }

  /// A small timer that periodically tries to store the phone’s “cached” position.
  /// If it succeeds in storing a brand-new cached point, we reset the GPS timer
  /// to avoid extra fetches for a bit.
  // Future<void> startCachedTimer() async {
  //   if (_cachedTimer == null || !_cachedTimer!.isActive) {
  //     _cachedTimer =
  //         Timer.periodic(const Duration(seconds: 5), _cachedTimerHandler);
  //   } else if (kDebugMode) {
  //     debugPrint(
  //         "[PointAutomation] Cached timer is already running; not starting a new one.");
  //   }
  // }

  Future<void> _cachedTimerHandler(Timer timer) async {
    if (kDebugMode) {
      debugPrint("[DEBUG] Creating point from cache");
    }

    if (_isTracking) {
      final Result<LocalPoint, String> optionPoint =
          await _localPointService.createPointFromCache(persist: true);

      if (optionPoint case Ok(value: final LocalPoint point)) {
        // We actually got a new point from the phone’s cache, so reset the GPS timer.
        // This basically says “we got a point anyway, so hold off on forcing another one too soon.”
        if (_serviceInstance is AndroidServiceInstance) {
          final androidService = _serviceInstance;
          final isForeground = await androidService.isForegroundService();
          if (isForeground) {
            androidService.setForegroundNotificationInfo(
              title: 'Tracking location...',
              content: 'Last updated at ${DateTime
                  .now()
                  .toLocal()
                  .toIso8601String()}',
            );
          }
        }
        await _restartGpsTimer();

        if (kDebugMode) {
          debugPrint(
              "[DEBUG: automatic point tracking] Cached point found! Storing it...");
        }
      } else if (kDebugMode) {
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
    final frequency = await _trackerPreferencesService
        .getTrackingFrequencyPreference();
    _gpsTimerFrequency = frequency;

    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(Duration(seconds: frequency), _gpsTimerHandler);

    if (kDebugMode) {
      debugPrint("[PointAutomation] Started GPS timer with $frequency second interval.");
    }
  }

  Future<void> updateTimers() async {

    if (_isTracking) {
      final int newFrequency = await _trackerPreferencesService.getTrackingFrequencyPreference();
      if (_gpsTimerFrequency != newFrequency) {
        await stopGpsTimer();
        await startGpsTimer();

      }
    }
  }

  /// Forces a new position fetch by calling localPointService.createNewPoint().
  Future<void> _gpsTimerHandler(Timer timer) async {

    if (!_isTracking || _isHandlingNewPoint) {
      return;
    }

    _isHandlingNewPoint = true;

    if (kDebugMode) {
      debugPrint("[PointAutomation] Creating new point from GPS");
    }

    try {
      final result = await _localPointService.createPointFromGps(persist: false);

      if (result case Ok(value: final point)) {
        onNewPoint(point);
      } else if (result case Err(value: final err)) {
        debugPrint("[PointAutomation] Forced GPS point not created: $err");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error creating new GPS point: $e\n$s");
    } finally {
      _isHandlingNewPoint = false;
    }

  }

  void onNewPoint(LocalPoint point) async {
    if (_serviceInstance is AndroidServiceInstance) {
      final isForeground = await _serviceInstance.isForegroundService();
      if (isForeground) {
        await _serviceInstance.setForegroundNotificationInfo(
          title: 'Tracking location...',
          content: 'Last updated at ${DateTime.now().toLocal().toIso8601String()}',
        );
      }

      _serviceInstance.invoke('newPoint', point.toJson());
    } else {
      // Main isolate handles storage directly
      final storeResult = await _localPointService.storePoint(point);
      if (storeResult case Ok()) {
        debugPrint("[PointAutomation] Successfully stored");
      } else if (storeResult case Err(value: String err)) {
        debugPrint("[PointAutomation] Failed to store point: $err");
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
    if (_isTracking) {
      await stopGpsTimer();
      await startGpsTimer();
    }
  }
}
