import 'dart:math' as math;
import 'dart:async';
import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/features/batch/application/usecases/batch_upload_workflow_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/get_current_batch_usecase.dart';
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/services/motion_detector_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_intelligence_service.dart';
import 'package:dawarich/features/tracking/application/usecases/get_batch_point_count_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/notifications/show_tracker_notification_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_from_location_stream_workflow.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/store_point_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/watch_tracker_settings_usecase.dart';
import 'package:dawarich/features/tracking/domain/enum/auto_tracking_runtime_mode.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';
import 'package:dawarich/features/tracking/domain/models/tracking_sample.dart';
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
  StreamSubscription<void>? _connectivitySub;
  StreamSubscription<void>? _motionSub;
  TrackerSettings? _currentSettings;
  Timer? _heartbeatTimer;
  Timer? _activeSilenceTimer;
  DateTime? _lastPointTime;
  int _lastKnownBatchCount = 0;
  int _recoveryAttempt = 0;

  /// When `true` the main-app Flutter engine is in the foreground.
  bool _isMainAppForegrounded = false;

  /// Guards the very first connectivity event after [startTracking].
  /// On startup the connectivity stream immediately emits the current state.
  /// We skip the WiFi → passive shortcut for that first event so the tracker
  /// always begins in active mode; subsequent WiFi connections (arriving home
  /// mid-session) still trigger passive mode normally.
  bool _startupConnectivityGuard = true;

  /// One-shot timer that re-enables the motion detector after a brief pause
  /// following the app coming to the foreground.  The pause covers the
  /// engine-initialisation window (~5 s) to avoid Dart-VM contention that
  /// could stall the first-frame render; after it expires the detector
  /// resumes so it keeps working while the user views the app.
  Timer? _foregroundResumeTimer;

  /// How long the motion detector stays paused after the app is foregrounded.
  /// 5 s is more than enough for Flutter engine initialisation to complete.
  static const Duration _foregroundMotionResumeDelay = Duration(seconds: 5);

  /// Maximum consecutive stream recovery attempts before giving up.
  /// After this, the service stays alive (notification visible) but stops
  /// retrying. The 15-min WorkManager watchdog will eventually restart it
  /// with a clean state.
  static const _maxRecoveryAttempts = 10;

  /// Heartbeat interval for re-posting the notification so aggressive OEMs
  /// Uses the cached batch count — no DB query.
  static const _heartbeatInterval = Duration(seconds: 60);

  AutoTrackingRuntimeMode get autoTrackingRuntimeMode =>
      _autoTrackingRuntimeMode;

  AutoTrackingRuntimeMode _autoTrackingRuntimeMode =
      AutoTrackingRuntimeMode.active;

  final CreatePointFromLocationStreamWorkflow _createPointFromLocationStream;
  final StorePointUseCase _storePoint;
  final GetBatchPointCountUseCase _getBatchPointCount;
  final ShowTrackerNotificationUseCase _showTrackerNotification;
  final GetCurrentBatchUseCase _getCurrentBatch;
  final BatchUploadWorkflowUseCase _batchUploadWorkflow;
  final WatchTrackerSettingsUseCase _watchTrackerSettings;
  final IPointLocalRepository _localPointRepository;
  final TrackerIntelligenceService _trackerIntelligenceService;
  final IHardwareRepository _hardwareRepository;
  final MotionDetectorService _motionDetector;


  PointAutomationService(
      this._createPointFromLocationStream,
      this._storePoint,
      this._getBatchPointCount,
      this._showTrackerNotification,
      this._getCurrentBatch,
      this._batchUploadWorkflow,
      this._watchTrackerSettings,
      this._localPointRepository,
      this._trackerIntelligenceService,
      this._hardwareRepository,
      this._motionDetector,
  );

  /// Whether automatic tracking is currently active
  bool get isTracking => _isTracking;

  Future<void> startTracking(int userId) async {

    if (_isTracking) {
      return;
    }

    if (kDebugMode) {
      debugPrint("[PointAutomation] Starting automatic tracking with location stream...");
    }

    _isTracking = true;
    _currentUserId = userId;
    _lastPointTime = null;
    _recoveryAttempt = 0;
    _startupConnectivityGuard = true;
    await _refreshNotification(userId);

    _trackerIntelligenceService.reset();
    _setAutoTrackingRuntimeMode(_trackerIntelligenceService.currentMode);

    _startHeartbeatTimer();
    _startSettingsWatch(userId);
    _startConnectivityWatch(userId);
    _startLocationStream(userId);
    _startBatchCountWatch(userId);
    _startMotionWatch(userId);
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

      final modeLabel = _autoTrackingRuntimeMode == AutoTrackingRuntimeMode.active
          ? 'ACTIVE'
          : 'PASSIVE';

      String body;
      if (_lastPointTime != null) {
        final lastTime = _lastPointTime!.toLocal();
        final lastTimeStr = '${lastTime.hour.toString().padLeft(2, '0')}:'
            '${lastTime.minute.toString().padLeft(2, '0')}:'
            '${lastTime.second.toString().padLeft(2, '0')}';
        body = '[$modeLabel] Last point: $lastTimeStr • $batchCount in batch';
      } else {
        body = '[$modeLabel] Monitoring location... • $batchCount in batch';
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

        if (_isTracking && settings.trackingFrequency == 0) {
          if (_autoTrackingRuntimeMode == AutoTrackingRuntimeMode.active) {
            _startOrResetActiveSilenceTimer(userId);
          } else {
            _cancelActiveSilenceTimer();
          }
        }

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

  // ── Connectivity watch ─────────────────────────────────────────────────────

  void _startConnectivityWatch(int userId) {
    _connectivitySub?.cancel();

    _connectivitySub = _hardwareRepository.watchConnectivity().listen(
      (kind) async {
        if (!_isTracking || _currentUserId != userId) return;

        // Skip the very first event emitted immediately on subscription.
        // connectivity_plus emits the current state at subscribe time, but we
        // always want the tracker to begin in active mode regardless of whether
        // the device is already on WiFi. Subsequent events (e.g. arriving home
        // mid-session) still apply the WiFi → passive shortcut normally.
        if (_startupConnectivityGuard) {
          _startupConnectivityGuard = false;
          if (kDebugMode) {
            debugPrint('[PointAutomation] Connectivity startup event suppressed ($kind)');
          }
          return;
        }

        final previousMode = _autoTrackingRuntimeMode;
        final nextMode = _trackerIntelligenceService.notifyConnectivityChanged(kind);

        if (kDebugMode) {
          debugPrint('[PointAutomation] Connectivity changed: $kind → mode $nextMode');
        }

        final settings = _currentSettings;
        final isAutoMode = settings?.trackingFrequency == 0;

        if (isAutoMode && previousMode != nextMode) {
          _setAutoTrackingRuntimeMode(nextMode);
          await _restartLocationStream(userId);
        }
      },
      onError: (e) {
        debugPrint('[PointAutomation] Connectivity watch error: $e');
      },
    );
  }

  // ── Motion-sensor watch ────────────────────────────────────────────────────

  /// Subscribes to the motion detector's stream.  The detector itself is only
  /// started/stopped by [_setAutoTrackingRuntimeMode], so this subscription
  /// just forwards events regardless of whether the sensor is active.
  void _startMotionWatch(int userId) {
    _motionSub?.cancel();
    _motionSub = _motionDetector.motionStream.listen(
      (_) => _handleMotionDetected(userId),
      onError: (Object e) {
        debugPrint('[PointAutomation] Motion watch error: $e');
      },
    );
  }

  /// Called when the accelerometer detects sustained motion while in passive
  /// mode.  Switches to active mode immediately — waiting for a one-shot GPS
  /// fix to "confirm" movement is unreliable because:
  ///
  ///   • At the start of a journey the GPS displacement since the last passive
  ///     fix is small and may not clear the accuracy-gated distance guard.
  ///   • Speed accuracy on non-GMS builds can be high enough that the
  ///     net-speed guard also fails.
  ///
  /// Instead, the accelerometer's 2/4-sample threshold (1.5 m/s²) is treated
  /// as sufficient evidence.  [TrackerIntelligenceService.notifyMotion] seeds
  /// [lastMeaningfulMovementTime] so the active-silence timer doesn't expire
  /// before the first confirming GPS fix arrives.  If subsequent GPS fixes do
  /// NOT confirm movement (false positive), the silence timer will still revert
  /// to passive after [TrackerIntelligenceService.passiveAfterStillness].
  Future<void> _handleMotionDetected(int userId) async {
    if (!_isTracking || _currentUserId != userId) return;
    if (_autoTrackingRuntimeMode != AutoTrackingRuntimeMode.passive) return;

    final settings = _currentSettings;
    if (settings?.trackingFrequency != 0) return; // only in auto mode

    if (kDebugMode) {
      debugPrint(
        '[PointAutomation] Motion sensor fired — switching to active immediately.',
      );
    }

    // Seed the intelligence service so the active-silence timer has a recent
    // movement timestamp to work with.
    _trackerIntelligenceService.notifyMotion(DateTime.now().toUtc());

    _setAutoTrackingRuntimeMode(AutoTrackingRuntimeMode.active);
    await _restartLocationStream(userId);
  }

  // ── Location stream ────────────────────────────────────────────────────────

  void _startLocationStream(int userId) {
    _locationStreamSub?.cancel();

    final Stream<TrackingSample> pointStream =
    _createPointFromLocationStream.getTrackingSampleStream(
        userId, runtimeMode: _autoTrackingRuntimeMode);

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

    _recoveryAttempt++;

    if (_recoveryAttempt > _maxRecoveryAttempts) {
      debugPrint(
        "[PointAutomation] Stream recovery exhausted ($_maxRecoveryAttempts attempts). "
        "Giving up — watchdog will restart the service.",
      );
      return;
    }

    // Exponential backoff: 2s, 4s, 8s, 16s, 32s, 64s, 128s, 256s, capped at 300s (5 min).
    final delaySec = math.min(math.pow(2, _recoveryAttempt).toInt(), 300);

    try {
      if (kDebugMode) {
        debugPrint(
          "[PointAutomation] Scheduling stream recovery (attempt $_recoveryAttempt) "
          "due to: $reason — waiting ${delaySec}s",
        );
      }

      await Future<void>.delayed(Duration(seconds: delaySec));

      if (!_isTracking || _currentUserId != userId) {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Stream recovery aborted: tracking no longer active.");
        }
        return;
      }

      await _restartLocationStream(userId);
    } catch (e, s) {
      debugPrint("[PointAutomation] Stream recovery failed: $e\n$s");
    }
  }

  Future<void> _restartLocationStream(int userId) async {
    try {
      if (_isRestartingStream) {
        return;
      }

      _isRestartingStream = true;

      final oldSub = _locationStreamSub;
      _locationStreamSub = null;

      if (oldSub != null) {
        try {
          await oldSub.cancel();
        } catch (e) {
          debugPrint("[PointAutomation] Cancel error (ignored): $e");
        }
      }

      _startLocationStream(userId);

      if (kDebugMode) {
        debugPrint("[PointAutomation] Location stream restarted");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] ERROR in _restartLocationStream: $e\n$s");
    } finally {
      _isRestartingStream = false;
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
    _recoveryAttempt = 0;
    _startupConnectivityGuard = true;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _foregroundResumeTimer?.cancel();
    _foregroundResumeTimer = null;
    _cancelActiveSilenceTimer();
    _trackerIntelligenceService.reset();
    _setAutoTrackingRuntimeMode(_trackerIntelligenceService.currentMode);
    await _batchCountSub?.cancel();
    _batchCountSub = null;
    await _settingsWatchSub?.cancel();
    _settingsWatchSub = null;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    await _motionSub?.cancel();
    _motionSub = null;
    _motionDetector.stop();
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
  Future<void> _handleLocationUpdate(TrackingSample sample, int userId) async {
    // A location update arrived — the stream is healthy. Reset the backoff
    // counter so the next failure starts from a short delay again.
    _recoveryAttempt = 0;

    try {
      final previousMode = _autoTrackingRuntimeMode;
      final nextMode = _trackerIntelligenceService.evaluateFix(sample.fix);

      final settings = _currentSettings;
      final isAutoMode = settings?.trackingFrequency == 0;
      final didModeValueChange = previousMode != nextMode;
      final shouldRestartForModeChange = isAutoMode == true && didModeValueChange;

      if (shouldRestartForModeChange) {
        if (kDebugMode) {
          debugPrint(
            '[PointAutomation] Auto tracking mode changed '
                '($previousMode -> $nextMode), restarting location stream...',
          );
        }


        _setAutoTrackingRuntimeMode(nextMode);
        await _restartLocationStream(userId);
      } else if (didModeValueChange) {
        _setAutoTrackingRuntimeMode(nextMode);
      }

      if (isAutoMode == true) {
        if (nextMode == AutoTrackingRuntimeMode.active) {
          _startOrResetActiveSilenceTimer(userId);
        } else {
          _cancelActiveSilenceTimer();
        }
      }

      final pointResult = sample.pointResult;
      if (pointResult == null) {
        if (kDebugMode) {
          debugPrint('[PointAutomation] No point created for this tracking sample.');
        }

        _refreshNotificationWithCount(_lastKnownBatchCount);
        return;
      }

      if (pointResult case Ok(value: final point)) {
        if (kDebugMode) {
          debugPrint('[PointAutomation] Storing point from location stream');
        }

        final storeResult = await _storePoint(point);

        if (storeResult case Ok()) {
          _lastPointTime = DateTime.now();
        } else if (storeResult case Err(value: final err)) {
          debugPrint('[PointAutomation] Failed to store point: $err');
        }

        _refreshNotificationWithCount(_lastKnownBatchCount);
        return;
      }

      if (pointResult case Err(value: final err)) {
        debugPrint('[PointAutomation] Point creation error: $err');
      }

      _refreshNotificationWithCount(_lastKnownBatchCount);
    } catch (e, s) {
      debugPrint('[PointAutomation] Error handling location update: $e\n$s');
    }
  }


  // ── Main-app foreground state ──────────────────────────────────────────────

  /// Called by the background-service event handler when the main app moves
  /// to the foreground ([foregrounded] = `true`) or background (`false`).
  ///
  /// On foregrounding the motion detector is paused briefly
  /// ([_foregroundMotionResumeDelay]) to prevent Dart-VM scheduling pressure
  /// from stalling the main-app engine's first-frame render.  Once the guard
  /// window expires the detector automatically resumes (if still passive) so
  /// it keeps working while the user has the app open — important for
  /// passive → active wake-ups during foreground use.
  void setMainAppForegrounded(bool foregrounded) {
    _isMainAppForegrounded = foregrounded;

    // Cancel any pending resume timer regardless of direction.
    _foregroundResumeTimer?.cancel();
    _foregroundResumeTimer = null;

    if (foregrounded) {
      // Stop the sensor for the brief initialisation window.
      _motionDetector.stop();

      // Schedule automatic re-enable after the guard window.
      _foregroundResumeTimer = Timer(_foregroundMotionResumeDelay, () {
        _foregroundResumeTimer = null;
        if (_isTracking &&
            _autoTrackingRuntimeMode == AutoTrackingRuntimeMode.passive) {
          if (kDebugMode) {
            debugPrint(
              '[PointAutomation] Foreground guard window passed — resuming motion detector.',
            );
          }
          _motionDetector.start();
        }
      });
    } else {
      // App went to background — resume immediately if passive.
      if (_isTracking &&
          _autoTrackingRuntimeMode == AutoTrackingRuntimeMode.passive) {
        _motionDetector.start();
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[PointAutomation] Main-app foregrounded=$foregrounded '
        '→ motion detector ${foregrounded ? "paused (${_foregroundMotionResumeDelay.inSeconds}s guard)" : "resumed"}',
      );
    }
  }

  // - Tracking intelligence───────────────────────────────────────────────────-

  void _setAutoTrackingRuntimeMode(AutoTrackingRuntimeMode mode) {
    if (_autoTrackingRuntimeMode == mode) {
      return;
    }

    _autoTrackingRuntimeMode = mode;
    _refreshNotificationWithCount(_lastKnownBatchCount);

    // Keep the motion detector running only while passive.  In active mode the
    // GPS fires frequently enough on its own and the sensor would just waste
    // the ~1 mA it draws.
    if (mode == AutoTrackingRuntimeMode.passive) {
      if (!_isMainAppForegrounded) {
        // Normal case — app is backgrounded.
        _motionDetector.start();
      } else if (_foregroundResumeTimer == null) {
        // App is foregrounded but the 5 s init-guard window has already
        // expired (timer fired and set itself to null).  Safe to start the
        // sensor now — engine initialisation is complete.
        _motionDetector.start();
        if (kDebugMode) {
          debugPrint(
            '[PointAutomation] Passive mode entered (foregrounded, init done) — '
            'starting motion detector immediately.',
          );
        }
      } else {
        // Still within the init-guard window.  The pending
        // _foregroundResumeTimer already checks _autoTrackingRuntimeMode
        // before starting the sensor, so it will handle this transition.
        if (kDebugMode) {
          debugPrint(
            '[PointAutomation] Passive mode entered during foreground init window — '
            'motion detector deferred to guard timer.',
          );
        }
      }
    } else {
      _motionDetector.stop();
    }

    if (kDebugMode) {
      debugPrint(
        '[PointAutomation] Auto tracking runtime mode -> $mode',
      );
    }
  }

  void _cancelActiveSilenceTimer() {
    _activeSilenceTimer?.cancel();
    _activeSilenceTimer = null;
  }

  void _startOrResetActiveSilenceTimer(int userId) {
    _cancelActiveSilenceTimer();

    final settings = _currentSettings;
    final isAutoMode = settings?.trackingFrequency == 0;

    if (isAutoMode != true) {
      return;
    }

    if (_autoTrackingRuntimeMode != AutoTrackingRuntimeMode.active) {
      return;
    }

    _activeSilenceTimer = Timer(
      TrackerIntelligenceService.passiveAfterStillness,
          () async {
        if (!_isTracking || _currentUserId != userId) {
          return;
        }

        final latestSettings = _currentSettings;
        final isStillAutoMode = latestSettings?.trackingFrequency == 0;

        if (isStillAutoMode != true) {
          return;
        }

        if (_autoTrackingRuntimeMode != AutoTrackingRuntimeMode.active) {
          return;
        }

        final now = DateTime.now().toUtc();

        final lastMovementTime =
            _trackerIntelligenceService.lastMeaningfulMovementTime ?? now.subtract(TrackerIntelligenceService.passiveAfterStillness);

        final stillFor = now.difference(lastMovementTime);

        if (stillFor < TrackerIntelligenceService.passiveAfterStillness) {
          if (kDebugMode) {
            debugPrint(
              '[PointAutomation] Passive timer elapsed, but movement was seen '
                  '${stillFor.inSeconds}s ago. Staying active.',
            );
          }
          _startOrResetActiveSilenceTimer(userId);
          return;
        }

        if (kDebugMode) {
          debugPrint(
            '[PointAutomation] No meaningful movement for '
                '${stillFor.inSeconds}s while active, switching to passive...',
          );
        }

        _setAutoTrackingRuntimeMode(AutoTrackingRuntimeMode.passive);
        await _restartLocationStream(userId);
      },
    );
  }


}
