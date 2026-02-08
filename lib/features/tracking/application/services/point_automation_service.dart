import 'dart:async';
import 'package:dawarich/features/batch/application/usecases/batch_upload_workflow_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/check_batch_threshold_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/get_current_batch_usecase.dart';
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

  late final ReactivePeriodicTicker _ticker;
  StreamSubscription<void>? _tickerSub;

  final WatchTrackerSettingsUseCase _watchTrackerSettings;
  final CreatePointFromGpsWorkflow _createPointFromGps;
  final CreatePointFromCacheWorkflow _createPointFromCache;
  final StorePointUseCase _storePoint;
  final GetBatchPointCountUseCase _getBatchPointCount;
  final ShowTrackerNotificationUseCase _showTrackerNotification;
  final CheckBatchThresholdUseCase _checkBatchThreshold;
  final GetCurrentBatchUseCase _getCurrentBatch;
  final BatchUploadWorkflowUseCase _batchUploadWorkflow;

  PointAutomationService(
      this._watchTrackerSettings,
      this._createPointFromGps,
      this._createPointFromCache,
      this._storePoint,
      this._getBatchPointCount,
      this._showTrackerNotification,
      this._checkBatchThreshold,
      this._getCurrentBatch,
      this._batchUploadWorkflow,
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
        if (kDebugMode) {
          debugPrint("[PointAutomation] Settings changed, frequency: ${seconds}s");
        }
        return Duration(seconds: seconds > 0 ? seconds : 10);
      }).distinct();

      _ticker = ReactivePeriodicTicker(freq$);
      _ticker.start(immediate: true);

      _tickerSub = _ticker.ticks.listen((_) async {
        await _tickHandler();
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

      await _tickerSub?.cancel();
      _tickerSub = null;

      await _ticker.stop();
      debugPrint("[PointAutomation] Tracking stopped");
    }

  }

  /// Unified tick handler - tries cache first, falls back to GPS if needed.
  Future<void> _tickHandler() async {
    final userId = _userId;
    if (userId == null) return;

    if (_writeBusy) {
      if (kDebugMode) {
        debugPrint("[PointAutomation] Skipping tick, write busy.");
      }
      return;
    }

    _writeBusy = true;

    try {
      // Try cache first (cheaper operation)
      final cacheResult = await _createPointFromCache(userId);

      if (cacheResult case Ok(value: final point)) {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Created point from cache");
        }
        final storeResult = await _storePoint(point);
        if (storeResult case Ok()) {
          await _notify(userId);
          await _checkAndUploadBatch(userId);
          return; // Success, no need to try GPS
        } else if (storeResult case Err(value: final err)) {
          debugPrint("[PointAutomation] Failed to store cached point: $err");
        }
      }

      // Cache failed or no cached data, try GPS
      if (kDebugMode) {
        debugPrint("[PointAutomation] Cache unavailable, fetching fresh GPS...");
      }

      final gpsResult = await _createPointFromGps(userId);

      if (gpsResult case Ok(value: final point)) {
        final storeResult = await _storePoint(point);
        if (storeResult case Ok()) {
          if (kDebugMode) {
            debugPrint("[PointAutomation] Created point from GPS");
          }
          await _notify(userId);
          await _checkAndUploadBatch(userId);
        } else if (storeResult case Err(value: final err)) {
          debugPrint("[PointAutomation] Failed to store GPS point: $err");
        }
      } else if (gpsResult case Err(value: final err)) {
        debugPrint("[PointAutomation] GPS point not created: $err");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error in tick handler: $e\n$s");
    } finally {
      _writeBusy = false;
    }
  }

  Future<void> _checkAndUploadBatch(int userId) async {
    try {
      final shouldUpload = await _checkBatchThreshold(userId);
      if (shouldUpload) {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Batch threshold reached, uploading...");
        }
        final batch = await _getCurrentBatch(userId);
        if (batch.isNotEmpty) {
          final result = await _batchUploadWorkflow(batch, userId);
          if (result case Ok()) {
            if (kDebugMode) {
              debugPrint("[PointAutomation] Batch upload successful.");
            }
          } else if (result case Err(value: final err)) {
            debugPrint("[PointAutomation] Batch upload failed: $err");
          }
        }
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error checking/uploading batch: $e\n$s");
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
