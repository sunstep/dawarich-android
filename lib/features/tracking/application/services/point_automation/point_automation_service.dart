import 'dart:async';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/features/tracking/application/services/point_automation/reactive_periodic_ticker.dart';
import 'package:dawarich/features/tracking/application/services/tracker_settings_service.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/services/tracking_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class PointAutomationService with ChangeNotifier {

  bool _isTracking = false;
  bool _writeBusy = false;

  late final ReactivePeriodicTicker _gpsTicker;
  late final ReactivePeriodicTicker _cacheTicker;

  StreamSubscription<void>? _gpsSub;
  StreamSubscription<void>? _cacheSub;

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

      final freq$ = (await _trackerPreferencesService.watchTrackingFrequencySetting())
          .distinct()
          .map((s) => Duration(seconds: (s > 0) ? s : 10))
          .handleError((_) {})
          .transform(StreamTransformer.fromBind((src) async* {
            yield const Duration(seconds: 10);
            yield* src.distinct();
          }));

      _gpsTicker = ReactivePeriodicTicker(freq$);
      _cacheTicker = ReactivePeriodicTicker(Stream.value(const Duration(seconds: 5)));

      _gpsTicker.start(immediate: true);
      _cacheTicker.start();

      _gpsSub = _gpsTicker.ticks.listen((_) async {
        await _gpsTimerHandler();
      });

      _cacheSub = _cacheTicker.ticks.listen((_) async {
        if (_writeBusy) {
          if (kDebugMode) {
            debugPrint("[PointAutomation] Skipping cached point creation, write busy.");
          }
          return;
        }

        if (kDebugMode) {
          debugPrint("[PointAutomation] Creating new GPS point...");
        }

        _writeBusy = true;

        try {
          final res = await _localPointService.createPointFromCache();
          if (res is Ok<LocalPoint, String>) {
            _gpsTicker.snooze();
            await _notify();
          }
        } catch (_) {
          if (kDebugMode) {
            debugPrint("[PointAutomation] Error creating new cached point.");
          }
        } finally {
          _writeBusy = false;
        }

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

      _isTracking = false;

      await _gpsSub?.cancel();
      _gpsSub = null;

      await _cacheSub?.cancel();
      _cacheSub = null;

      await _gpsTicker.stop();
      await _cacheTicker.stop();
      debugPrint("[PointAutomation] Tracking stopped");
    }

  }

  /// Forces a new position fetch by calling localPointService.createNewPoint().
  Future<void> _gpsTimerHandler() async {

    if (_writeBusy) {
      if (kDebugMode) {
        debugPrint("[PointAutomation] Skipping GPS point creation, write busy.");
      }
      return;
    }

    if (kDebugMode) {
      debugPrint("[PointAutomation] Creating new GPS point...");
    }

    _writeBusy = true;

    try {
      final result = await _localPointService.createPointFromGps();

      if (result case Ok(value: final LocalPoint point)) {
       await _notify();
      } else if (result case Err(value: final err)) {
        debugPrint("[PointAutomation] Forced GPS point not created: $err");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error creating new GPS point: $e\n$s");
    } finally {
      _writeBusy = false;
    }

  }

  Future<void> _notify() async {
    try {
      await _notificationService.showOrUpdate(
        title: 'Tracking location...',
        body: 'Last updated at ${DateTime.now().toLocal().toIso8601String()}, '
            '${await _localPointService.getBatchPointsCount()} points in batch.',
      );
    } catch (e, s) {
      debugPrint("[PointAutomation] Notify error: $e\n$s");
    }
  }

}
