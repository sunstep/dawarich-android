import 'dart:async';
import 'package:dawarich/features/batch/application/usecases/batch_upload_workflow_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/check_batch_threshold_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/get_current_batch_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/get_batch_point_count_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/notifications/show_tracker_notification_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_from_location_stream_workflow.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/store_point_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/watch_tracker_settings_usecase.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class PointAutomationService {
  bool _isTracking = false;
  bool _writeBusy = false;
  int? _currentUserId;
  StreamSubscription<Result<dynamic, String>>? _locationStreamSub;
  StreamSubscription<TrackerSettings>? _settingsWatchSub;
  TrackerSettings? _currentSettings;

  final CreatePointFromLocationStreamWorkflow _createPointFromLocationStream;
  final StorePointUseCase _storePoint;
  final GetBatchPointCountUseCase _getBatchPointCount;
  final ShowTrackerNotificationUseCase _showTrackerNotification;
  final CheckBatchThresholdUseCase _checkBatchThreshold;
  final GetCurrentBatchUseCase _getCurrentBatch;
  final BatchUploadWorkflowUseCase _batchUploadWorkflow;
  final WatchTrackerSettingsUseCase _watchTrackerSettings;

  PointAutomationService(
    this._createPointFromLocationStream,
    this._storePoint,
    this._getBatchPointCount,
    this._showTrackerNotification,
    this._checkBatchThreshold,
    this._getCurrentBatch,
    this._batchUploadWorkflow,
    this._watchTrackerSettings,
  );

  /// Whether automatic tracking is currently active
  bool get isTracking => _isTracking;

  Future<void> startTracking(int userId) async {
    if (_isTracking) return;

    if (kDebugMode) {
      debugPrint("[PointAutomation] Starting automatic tracking with location stream...");
    }

    _isTracking = true;
    _currentUserId = userId;

    _startSettingsWatch(userId);

    _startLocationStream(userId);
  }

  void _startSettingsWatch(int userId) {
    _settingsWatchSub?.cancel();

    if (kDebugMode) {
      debugPrint("[PointAutomation] Starting settings watch for userId: $userId");
    }

    _settingsWatchSub = _watchTrackerSettings(userId).listen(
      (settings) async {
        if (_currentSettings != null && _settingsRequireRestart(_currentSettings!, settings)) {
          if (kDebugMode) {
            debugPrint("[PointAutomation] Settings changed (${_currentSettings!.trackingFrequency}s -> ${settings.trackingFrequency}s), restarting location stream...");
          }
          _currentSettings = settings;
          await _restartLocationStream(userId);
        } else {
          _currentSettings = settings;
        }
      },
      onError: (e) {
        debugPrint("[PointAutomation] Settings watch error: $e");
      },
    );
  }

  bool _settingsRequireRestart(TrackerSettings old, TrackerSettings current) {
    return old.trackingFrequency != current.trackingFrequency ||
           old.locationPrecision != current.locationPrecision ||
           old.minimumPointDistance != current.minimumPointDistance;
  }

  void _startLocationStream(int userId) {
    _locationStreamSub?.cancel();

    final pointStream = _createPointFromLocationStream.getPointStream(userId);

    _locationStreamSub = pointStream.listen(
      (result) async {
        await _handleLocationUpdate(result, userId);
      },
      onError: (error, stackTrace) {
        debugPrint("[PointAutomation] Stream error: $error\n$stackTrace");
      },
      onDone: () {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Location stream completed");
        }
      },
      cancelOnError: false,
    );
  }

  Future<void> _restartLocationStream(int userId) async {
    try {
      // Grab reference to old subscription and immediately null it out
      final oldSub = _locationStreamSub;
      _locationStreamSub = null;

      // Fire and forget the cancel - don't wait for it at all
      if (oldSub != null) {
        unawaited(oldSub.cancel().catchError((e) {
          debugPrint("[PointAutomation] Cancel error (ignored): $e");
        }));
      }

      // Start new location stream immediately
      _startLocationStream(userId);

      if (kDebugMode) {
        debugPrint("[PointAutomation] Location stream restarted");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] ERROR in _restartLocationStream: $e\n$s");
    }
  }

  /// Stop everything if user logs out, or toggles the preference off.
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    if (kDebugMode) {
      debugPrint("[PointAutomation] Stopping automatic tracking...");
    }

    _isTracking = false;
    _currentUserId = null;
    _currentSettings = null;
    await _settingsWatchSub?.cancel();
    _settingsWatchSub = null;
    await _locationStreamSub?.cancel();
    _locationStreamSub = null;
  }

  /// Restart tracking to apply new settings (e.g., frequency change)
  Future<void> restartTracking() async {
    if (!_isTracking || _currentUserId == null) return;

    final userId = _currentUserId!;

    if (kDebugMode) {
      debugPrint("[PointAutomation] Restarting tracking to apply new settings...");
    }

    await stopTracking();
    await startTracking(userId);
  }

  /// Handles location updates from the stream
  Future<void> _handleLocationUpdate(Result<dynamic, String> result, int userId) async {
    if (_writeBusy) {
      if (kDebugMode) {
        debugPrint("[PointAutomation] Skipping location update, write busy.");
      }
      return;
    }

    _writeBusy = true;

    try {
      if (result case Ok(value: final point)) {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Storing point from location stream");
        }

        final storeResult = await _storePoint(point);

        if (storeResult case Ok()) {
          await _notify(userId);
          await _checkAndUploadBatch(userId);
        } else if (storeResult case Err(value: final err)) {
          debugPrint("[PointAutomation] Failed to store point: $err");
        }
      } else if (result case Err(value: final err)) {
        debugPrint("[PointAutomation] Point creation error: $err");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error handling location update: $e\n$s");
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
