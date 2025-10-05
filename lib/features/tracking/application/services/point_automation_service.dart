import 'dart:async';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_settings_service.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/services/tracking_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:option_result/option_result.dart';

final class PointAutomationService with ChangeNotifier {

  bool _isTracking = false;
  bool _gpsLoopRunning = false;
  Duration _gpsPeriod = const Duration(seconds: 10);
  Completer<void>? _gpsLoopCompleter;
  StreamSubscription<int>? _frequencyListener;
  static const _ch = MethodChannel('dawarich/keepalive');

  final TrackerSettingsService _trackerPreferencesService;
  final LocalPointService _localPointService;
  final TrackingNotificationService _notificationService;

  PointAutomationService(this._trackerPreferencesService,
      this._localPointService, this._notificationService);

  Future<void> startTracking() async {

    if (kDebugMode) {
      debugPrint("[PointAutomation] Starting automatic tracking if not already started...");
    }

    if (!_isTracking) {

      if (kDebugMode) {
        debugPrint("[PointAutomation] Starting automatic tracking...");
      }

      _isTracking = true;

      await _startGpsLoop();
      // await startCachedTimer();

      _frequencyListener?.cancel();

      final Stream<int> stream = await _trackerPreferencesService
          .watchTrackingFrequencySetting();

      _frequencyListener = stream.distinct().listen((final int frequency) {

        if (kDebugMode) {
          debugPrint("[PointAutomation] Frequency changed to $frequency seconds");
        }

        _gpsPeriod = Duration(seconds: (frequency > 0) ? frequency : 10);
        _completeGpsLoop();
      });

    }
  }

  /// Stop everything if user logs out, or toggles the preference off.
  Future<void> stopTracking() async {

    if (kDebugMode) {
      debugPrint("[PointAutomation] Stopping automatic tracking if active...");
    }

    if (_isTracking) {

      if (kDebugMode) {
        debugPrint("[PointAutomation] Stopping automatic tracking...");
      }

      _stopGpsLoop();
      await _frequencyListener?.cancel();
      _frequencyListener = null;
      _isTracking = false;
      debugPrint("[PointAutomation] Tracking stopped");
    }

  }

  /// A timer that forces a brand new location fetch from Geolocator every N seconds
  /// (based on user’s preference).
  Future<void> _startGpsLoop() async {

    final int frequency = await _trackerPreferencesService.getTrackingFrequencySetting();
    _gpsPeriod = Duration(seconds: (frequency > 0) ? frequency : 10);

    if (_gpsLoopRunning) {
      _completeGpsLoop();
      return;
    }

    _gpsLoopRunning = true;

    if (kDebugMode) {
      debugPrint("[PointAutomation] Started GPS loop with ${_gpsPeriod.inSeconds}s interval.");
    }

    () async {
      try {
        while (_gpsLoopRunning) {
          final sw = Stopwatch()..start();

          await _gpsLoopHandler();

          final elapsed = sw.elapsed;
          final remaining = _gpsPeriod - elapsed;

          _gpsLoopCompleter = Completer<void>();
          if (remaining > Duration.zero) {
            await Future.any([
              Future.delayed(remaining),
              _gpsLoopCompleter!.future,
            ]);
          } else {
            await Future.any([
              Future.value(),
              _gpsLoopCompleter!.future,
            ]);
          }
          _gpsLoopCompleter = null;
        }
        if (kDebugMode) {
          debugPrint("[PointAutomation] GPS loop exited.");
        }
      } catch (e, s) {
        debugPrint("[PointAutomation] Error in GPS loop: $e\n$s");
        _completeGpsLoop();
      }
    }();
  }

  /// Forces a new position fetch by calling localPointService.createNewPoint().
  Future<void> _gpsLoopHandler() async {

    if (!_isTracking || !_gpsLoopRunning) {

      if (kDebugMode) {
        debugPrint("[PointAutomation] Not tracking, stopping GPS handler.");
      }

      return;
    }

    if (kDebugMode) {
      debugPrint("[PointAutomation] Creating new point from GPS");
    }

    try {

      final result = await _localPointService.createPointFromGps(persist: true);

      if (result case Ok(value: final LocalPoint point)) {
        await _notificationService.showOrUpdate(
          title: 'Tracking location...',
          body: 'Last updated at ${DateTime.now().toLocal().toIso8601String()}, '
              '${await _localPointService.getBatchPointsCount()} points in batch.',
        );
        _updateHeartbeat();
      } else if (result case Err(value: final err)) {
        debugPrint("[PointAutomation] Forced GPS point not created: $err");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error creating new GPS point: $e\n$s");
    }

  }


  /// Cancels and restarts the GPS timer. Called when we’ve just stored a cached point
  /// so we don’t spam the device with forced GPS calls too soon.
  Future<void> _completeGpsLoop() async {
    if (_isTracking) {
      final Completer<void>? completer = _gpsLoopCompleter;

      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }

      _gpsLoopCompleter = null;
    }
  }

  Future<void> _stopGpsLoop() async {

    if (!_gpsLoopRunning) {
      return;
    }
    _gpsLoopRunning = false;
    await _completeGpsLoop();
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
        await _notificationService.showOrUpdate(
          title: 'Tracking location...',
          body: 'Last updated at ${DateTime.now().toLocal().toIso8601String()}, '
              '${await _localPointService.getBatchPointsCount()} points in batch.',
        );

        await _completeGpsLoop();

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

  }

  Future<void> _updateHeartbeat() async {
    try {
      await _ch.invokeMethod('updateHeartbeat');
    } catch (_) {}
  }

}
