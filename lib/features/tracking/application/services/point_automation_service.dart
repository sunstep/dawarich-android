import 'dart:async';
import 'package:dawarich/features/tracking/application/usecases/get_batch_point_count_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/notifications/show_tracker_notification_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_from_cache_workflow.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_from_gps_workflow.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/store_point_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/watch_tracker_settings_usecase.dart';
import 'package:dawarich/features/tracking/data/repositories/reactive_periodic_ticker.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class PointAutomationService {

  bool _isTracking = false;
  bool _writeBusy = false;
  int? _userId;

  late final ReactivePeriodicTicker _gpsTicker;
  late final ReactivePeriodicTicker _cacheTicker;

  StreamSubscription<void>? _gpsSub;
  StreamSubscription<void>? _cacheSub;

  final WatchTrackerSettingsUseCase _watchTrackerSettings;
  final CreatePointFromGpsWorkflow _createPointFromGps;
  final CreatePointFromCacheWorkflow _createPointFromCache;
  final StorePointUseCase _storePoint;
  final GetBatchPointCountUseCase _getBatchPointCount;
  final ShowTrackerNotificationUseCase _showTrackerNotification;

  PointAutomationService(
      this._watchTrackerSettings,
      this._createPointFromGps,
      this._createPointFromCache,
      this._storePoint,
      this._getBatchPointCount,
      this._showTrackerNotification
  );

  Future<void> startTracking(int userId) async {

    if (kDebugMode) {
      debugPrint("[PointAutomation] Starting automatic tracking if not already started...");
    }

    if (!_isTracking) {

      if (kDebugMode) {
        debugPrint("[PointAutomation] Starting automatic tracking...");
      }

      _isTracking = true;
      _userId = userId;

      final freq$ = _watchTrackerSettings(userId)
          .map((s) {
        final seconds = s.trackingFrequency;
        return Duration(seconds: seconds > 0 ? seconds : 10);
      }).distinct();

      _gpsTicker = ReactivePeriodicTicker(freq$);
      _cacheTicker = ReactivePeriodicTicker(Stream.value(const Duration(seconds: 5)));

      _gpsTicker.start(immediate: true);
      _cacheTicker.start();

      _gpsSub = _gpsTicker.ticks.listen((_) async {
        await _gpsTimerHandler();
      });

      _cacheSub = _cacheTicker.ticks.listen((_) async {

        await _cacheTimerHandler();
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
      _userId = null;

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
    final userId = _userId;
    if (userId == null) return;

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
      final result = await _createPointFromGps(userId);

      if (result case Ok(value: final point)) {
        // Store the point in the database
        final storeResult = await _storePoint(point);
        if (storeResult case Ok()) {
          await _notify(userId);
        } else if (storeResult case Err(value: final err)) {
          debugPrint("[PointAutomation] Failed to store GPS point: $err");
        }
      } else if (result case Err(value: final err)) {
        debugPrint("[PointAutomation] Forced GPS point not created: $err");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error creating new GPS point: $e\n$s");
    } finally {
      _writeBusy = false;
    }

  }

  Future<void> _cacheTimerHandler() async {
    final userId = _userId;
    if (userId == null) return;

    if (_writeBusy) {
      if (kDebugMode) {
        debugPrint("[PointAutomation] Skipping cached point creation, write busy.");
      }
      return;
    }

    if (kDebugMode) {
      debugPrint("[PointAutomation] Creating new cached point...");
    }

    _writeBusy = true;

    try {
      final res = await _createPointFromCache(userId);
      if (res case Ok(value: final point)) {
        // Store the point in the database
        final storeResult = await _storePoint(point);
        if (storeResult case Ok()) {
          _gpsTicker.snooze();
          await _notify(userId);
        } else if (storeResult case Err(value: final err)) {
          debugPrint("[PointAutomation] Failed to store cached point: $err");
        }
      }
    } catch (_) {
      if (kDebugMode) {
        debugPrint("[PointAutomation] Error creating new cached point.");
      }
    } finally {
      _writeBusy = false;
    }
  }

  Future<void> _notify(int userId) async {
    try {
      await _showTrackerNotification(
        title: 'Tracking location...',
        body: 'Last updated at ${DateTime.now().toLocal().toIso8601String()}, '
            '${await _getBatchPointCount(userId)} points in batch.',
      );
    } catch (e, s) {
      debugPrint("[PointAutomation] Notify error: $e\n$s");
    }
  }
}
