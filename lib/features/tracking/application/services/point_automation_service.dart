import 'dart:async';
import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/batch/application/usecases/batch_upload_workflow_usecase.dart';
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
  bool _uploadBusy = false;
  bool _isRestartingStream = false;
  int? _currentUserId;
  StreamSubscription<void>? _locationStreamSub;
  StreamSubscription<TrackerSettings>? _settingsWatchSub;
  StreamSubscription<int>? _batchCountSub;
  TrackerSettings? _currentSettings;
  Timer? _heartbeatTimer;
  DateTime? _lastPointTime;
  int _lastKnownBatchCount = 0;

  /// Heartbeat interval for re-posting the notification so aggressive OEMs
  /// (Xiaomi, Huawei, Samsung) don't kill the foreground service.
  /// Uses the cached batch count — no DB query.
  static const _heartbeatInterval = Duration(seconds: 60);

  final CreatePointFromLocationStreamWorkflow _createPointFromLocationStream;
  final StorePointUseCase _storePoint;
  final GetBatchPointCountUseCase _getBatchPointCount;
  final ShowTrackerNotificationUseCase _showTrackerNotification;
  final GetCurrentBatchUseCase _getCurrentBatch;
  final BatchUploadWorkflowUseCase _batchUploadWorkflow;
  final WatchTrackerSettingsUseCase _watchTrackerSettings;
  final IPointLocalRepository _localPointRepository;

  PointAutomationService(
    this._createPointFromLocationStream,
    this._storePoint,
    this._getBatchPointCount,
    this._showTrackerNotification,
    this._getCurrentBatch,
    this._batchUploadWorkflow,
    this._watchTrackerSettings,
    this._localPointRepository,
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
    _lastPointTime = null;

    await _refreshNotification(userId);

    _startHeartbeatTimer();
    _startSettingsWatch(userId);
    _startLocationStream(userId);
    _startBatchCountWatch(userId);
  }

  // ── Heartbeat (OEM keep-alive) ─────────────────────────────────────────

  /// Re-posts the notification periodically using cached data (no DB query)
  /// so aggressive Android OEMs don't kill the foreground service for being
  /// "idle". This is purely a keep-alive signal.
  void _startHeartbeatTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      _heartbeatInterval,
      (_) => _refreshNotificationWithCount(_lastKnownBatchCount),
    );
  }

  // ── Notification ───────────────────────────────────────────────────────

  /// Refreshes the notification. Called reactively when the batch count
  /// changes or after an upload — not on a timer.
  Future<void> _refreshNotification(int userId) async {
    try {
      final batchCount = await _getBatchPointCount(userId);
      _refreshNotificationWithCount(batchCount);
    } catch (e, s) {
      debugPrint("[PointAutomation] Notification refresh error: $e\n$s");
    }
  }

  /// Updates the notification using an already-known batch count,
  /// avoiding an extra DB query.
  void _refreshNotificationWithCount(int batchCount) {
    try {
      String body;
      if (_lastPointTime != null) {
        final lastTime = _lastPointTime!.toLocal();
        final lastTimeStr = '${lastTime.hour.toString().padLeft(2, '0')}:'
            '${lastTime.minute.toString().padLeft(2, '0')}:'
            '${lastTime.second.toString().padLeft(2, '0')}';
        body = 'Last point: $lastTimeStr • $batchCount in batch';
      } else {
        body = 'Waiting for location... • $batchCount in batch';
      }

      _showTrackerNotification(
        title: 'Tracking active',
        body: body,
      );
    } catch (e, s) {
      debugPrint("[PointAutomation] Notification refresh error: $e\n$s");
    }
  }

  // ── Reactive batch count → threshold upload ────────────────────────────

  /// Watches the un-uploaded point count via a Drift reactive stream.
  /// Every time the count changes (point stored, upload completed, etc.)
  /// we check if the threshold is met and upload. Also refreshes the
  /// notification so the user always sees the current batch count.
  void _startBatchCountWatch(int userId) {
    _batchCountSub?.cancel();

    final stream = _localPointRepository.watchBatchPointCount(userId);

    _batchCountSub = stream.listen(
      (count) async {
        // Cache for the heartbeat timer.
        _lastKnownBatchCount = count;

        // Update notification reactively — only when the count actually changes.
        _refreshNotificationWithCount(count);

        final settings = _currentSettings;
        if (settings == null) return;

        if (count >= settings.pointsPerBatch) {
          if (kDebugMode) {
            debugPrint(
              '[PointAutomation] Batch count $count >= ${settings.pointsPerBatch} '
              '— uploading reactively',
            );
          }
          await _uploadCurrentBatch(userId);
        }
      },
      onError: (e) {
        debugPrint('[PointAutomation] Batch count watch error: $e');
      },
    );
  }

  // ── Upload helper ──────────────────────────────────────────────────────

  /// Fetches the current un-uploaded batch and uploads it.
  /// Guarded by [_uploadBusy] to prevent overlapping uploads.
  Future<void> _uploadCurrentBatch(int userId) async {
    if (_uploadBusy) return;
    _uploadBusy = true;

    try {
      final batch = await _getCurrentBatch(userId);
      if (batch.isEmpty) return;

      final result = await _batchUploadWorkflow(batch, userId);
      if (result case Ok()) {
        if (kDebugMode) {
          debugPrint('[PointAutomation] Batch upload successful.');
        }
      } else if (result case Err(value: final err)) {
        debugPrint('[PointAutomation] Batch upload failed: $err');
      }
    } catch (e, s) {
      debugPrint('[PointAutomation] Upload error: $e\n$s');
    } finally {
      _uploadBusy = false;
    }
  }

  // ── Settings watch ─────────────────────────────────────────────────────

  void _startSettingsWatch(int userId) {
    _settingsWatchSub?.cancel();

    if (kDebugMode) {
      debugPrint("[PointAutomation] Starting settings watch for userId: $userId");
    }

    _settingsWatchSub = _watchTrackerSettings(userId).listen(
      (settings) async {
        final old = _currentSettings;
        _currentSettings = settings;

        if (old != null && _settingsRequireRestart(old, settings)) {
          if (kDebugMode) {
            debugPrint("[PointAutomation] Settings changed (${old.trackingFrequency}s -> ${settings.trackingFrequency}s), restarting location stream...");
          }
          await _restartLocationStream(userId);
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

  // ── Location stream ────────────────────────────────────────────────────

  void _startLocationStream(int userId) {
    _locationStreamSub?.cancel();

    final Stream<Result<LocalPoint, String>> pointStream =
      _createPointFromLocationStream.getPointStream(userId);

    _locationStreamSub = pointStream
        .asyncMap((result) => _handleLocationUpdate(result, userId))
        .listen(
          (_) {},
      onError: (error, stackTrace) {
        debugPrint("[PointAutomation] Stream error: $error\n$stackTrace");
        unawaited(_scheduleLocationStreamRecovery(userId, 'stream error'));
      },
      onDone: () {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Location stream completed");
        }
        unawaited(_scheduleLocationStreamRecovery(userId, 'stream completed'));
      },
      cancelOnError: false,
    );
  }

  Future<void> _scheduleLocationStreamRecovery(int userId, String reason) async {
    if (!_isTracking || _currentUserId != userId) {
      if (kDebugMode) {
        debugPrint("[PointAutomation] Stream recovery skipped: tracking no longer active.");
      }
      return;
    }

    if (_isRestartingStream) {
      if (kDebugMode) {
        debugPrint("[PointAutomation] Stream recovery skipped: restart already in progress.");
      }
      return;
    }

    _isRestartingStream = true;

    try {
      if (kDebugMode) {
        debugPrint("[PointAutomation] Scheduling stream recovery due to: $reason");
      }

      await Future<void>.delayed(const Duration(seconds: 2));

      if (!_isTracking || _currentUserId != userId) {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Stream recovery aborted: tracking no longer active.");
        }
        return;
      }

      await _restartLocationStream(userId);
    } catch (e, s) {
      debugPrint("[PointAutomation] Stream recovery failed: $e\n$s");
    } finally {
      _isRestartingStream = false;
    }
  }

  Future<void> _restartLocationStream(int userId) async {
    try {
      final oldSub = _locationStreamSub;
      _locationStreamSub = null;

      if (oldSub != null) {
        unawaited(oldSub.cancel().catchError((e) {
          debugPrint("[PointAutomation] Cancel error (ignored): $e");
        }));
      }

      _startLocationStream(userId);

      if (kDebugMode) {
        debugPrint("[PointAutomation] Location stream restarted");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] ERROR in _restartLocationStream: $e\n$s");
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────

  Future<void> stopTracking() async {
    if (!_isTracking) return;

    if (kDebugMode) {
      debugPrint("[PointAutomation] Stopping automatic tracking...");
    }

    _isTracking = false;
    _isRestartingStream = false;
    _currentUserId = null;
    _currentSettings = null;
    _lastPointTime = null;
    _lastKnownBatchCount = 0;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    await _batchCountSub?.cancel();
    _batchCountSub = null;
    await _settingsWatchSub?.cancel();
    _settingsWatchSub = null;
    await _locationStreamSub?.cancel();
    _locationStreamSub = null;
  }

  Future<void> restartTracking() async {
    if (!_isTracking || _currentUserId == null) return;

    final userId = _currentUserId!;

    if (kDebugMode) {
      debugPrint("[PointAutomation] Restarting tracking to apply new settings...");
    }

    await stopTracking();
    await startTracking(userId);
  }

  // ── Location update handler (store only) ───────────────────────────────

  /// Handles location updates from the stream.
  /// Only stores the point locally. The reactive [_batchCountSub] stream
  /// picks up the count change and triggers the upload when the threshold
  /// is met.
  Future<void> _handleLocationUpdate(Result<LocalPoint, String> result, int userId) async {
    try {
      if (result case Ok(value: final point)) {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Storing point from location stream");
        }

        final storeResult = await _storePoint(point);

        if (storeResult case Ok()) {
          _lastPointTime = DateTime.now();
        } else if (storeResult case Err(value: final err)) {
          debugPrint("[PointAutomation] Failed to store point: $err");
        }
      } else if (result case Err(value: final err)) {
        debugPrint("[PointAutomation] Point creation error: $err");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error handling location update: $e\n$s");
    }
  }
}
