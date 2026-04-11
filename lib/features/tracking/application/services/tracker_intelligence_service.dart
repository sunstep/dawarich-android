import 'dart:math' as math;

import 'package:dawarich/features/tracking/domain/enum/auto_tracking_runtime_mode.dart';
import 'package:dawarich/features/tracking/domain/enum/connectivity_kind.dart';
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:geolocator/geolocator.dart';


final class TrackerIntelligenceService {
  AutoTrackingRuntimeMode _currentMode = AutoTrackingRuntimeMode.active;
  DateTime? _lastMeaningfulMovementTime;
  LocationFix? _lastObservedFix;

  /// True while the device is connected to a WiFi network.
  ///
  /// Used only as a one-shot passive trigger: when the device connects to WiFi
  /// [notifyConnectivityChanged] immediately sets the mode to passive (fast
  /// path for arriving at a known stationary location).  The movement guards
  /// in [evaluateFix] still run on every fix regardless, so detected movement
  /// (e.g. a train or bus with onboard WiFi) will override the passive state
  /// and switch back to active normally.
  bool _isOnWifi = false;

  static const Duration passiveAfterStillness = Duration(minutes: 1);

  /// Thresholds used when deciding whether a GPS fix confirms the device is
  /// moving while already in **passive** mode (passive → active wake-up).
  /// These are intentionally strict so that low-accuracy passive-mode fixes
  /// (balanced / lowPower precision, ±30–100 m) don't spam spurious wakeups.
  static const double activeWakeThresholdMeters = 25;
  static const double activeWakeSpeedThresholdMps = 2.0;

  /// Thresholds used to keep [_lastMeaningfulMovementTime] fresh while already
  /// in **active** mode.  They must be low enough to catch normal walking
  /// (~1.4–1.6 m/s, ~10–15 m per 10 s fix interval) so the one-minute silence
  /// timer does not prematurely switch a walking user to passive mode.
  ///
  /// Using the same strict [activeWakeThresholdMeters] / [activeWakeSpeedThresholdMps]
  /// here was the root cause of active → passive flipping mid-walk:
  ///   • Speed guard: 1.5 m/s walking − 0.5 m/s GPS accuracy = 1.0 net m/s < 2.0
  ///   • Distance guard: ~15 m per fix < 25 m threshold → both guards fail
  ///   → _lastMeaningfulMovementTime never updates → timer fires → passive.
  static const double activeKeepSpeedThresholdMps = 0.8;  // ≈ slow walk
  static const double activeKeepDistanceMeters = 10.0;    // one city-block step

  AutoTrackingRuntimeMode get currentMode => _currentMode;
  DateTime? get lastMeaningfulMovementTime => _lastMeaningfulMovementTime;

  void reset() {
    _currentMode = AutoTrackingRuntimeMode.active;
    _lastMeaningfulMovementTime = null;
    _lastObservedFix = null;
    _isOnWifi = false;
  }

  /// Called by the motion detector to record that physical motion was observed
  /// before a confirming GPS fix is available.
  ///
  /// Seeding [_lastMeaningfulMovementTime] here prevents the active-silence
  /// timer (which starts on the first GPS fix after a mode switch) from
  /// expiring prematurely in the gap between the accelerometer event and the
  /// first active-mode GPS fix.  If the subsequent GPS fixes do not confirm
  /// real movement the timer will still fire after [passiveAfterStillness] and
  /// revert to passive normally.
  void notifyMotion(DateTime atTime) {
    _lastMeaningfulMovementTime = atTime;
    _currentMode = AutoTrackingRuntimeMode.active;
  }

  /// Called whenever the device's network connectivity changes.
  ///
  /// Returns the new [AutoTrackingRuntimeMode] so the caller can decide
  /// whether to restart the location stream.
  ///
  /// WiFi connected → immediately passive.  This is a fast path for arriving
  /// at a stationary location (home, office, etc.).  The movement guards in
  /// [evaluateFix] continue to run on every subsequent fix, so if the device
  /// is actually moving while on WiFi (train, bus, tethered hotspot) the
  /// guards will detect it and switch back to active without any extra logic.
  ///
  /// WiFi lost → clear the movement baseline so the position guards evaluate
  /// from scratch on the next fix.  Mode is not forced; the first confirming
  /// fix after leaving WiFi decides whether the user is moving.
  AutoTrackingRuntimeMode notifyConnectivityChanged(ConnectivityKind kind) {
    final wasOnWifi = _isOnWifi;
    _isOnWifi = kind == ConnectivityKind.wifi;

    if (_isOnWifi && !wasOnWifi) {
      // Only go passive immediately if there is no evidence of current movement.
      // If _lastMeaningfulMovementTime was updated recently (within
      // passiveAfterStillness) the device was already moving when WiFi
      // connected, e.g. a train that was in motion when the user's phone
      // joined the onboard network.  In that case skip the passive switch and
      // let the movement guards decide normally; they will transition to passive
      // once the device has been still for passiveAfterStillness.
      final lastMoved = _lastMeaningfulMovementTime;
      final isLikelyMoving = lastMoved != null &&
          DateTime.now().toUtc().difference(lastMoved) < passiveAfterStillness;

      if (!isLikelyMoving) {
        _currentMode = AutoTrackingRuntimeMode.passive;
      }
    } else if (!_isOnWifi && wasOnWifi) {
      // Just left WiFi reset baseline so the next fix is evaluated fresh.
      _lastMeaningfulMovementTime = null;
      _lastObservedFix = null;
    }

    return _currentMode;
  }

  AutoTrackingRuntimeMode evaluateFix(LocationFix fix) {

    final lastFix = _lastObservedFix;
    double distanceMeters = 0;

    if (lastFix != null) {
      distanceMeters = Geolocator.distanceBetween(
        lastFix.latitude,
        lastFix.longitude,
        fix.latitude,
        fix.longitude,
      );
    }

    // ── Mode-aware movement detection ─────────────────────────────────────────
    //
    // Two separate guard sets are used:
    //
    //  • PASSIVE mode  → ACTIVE wake: strict guards (the motion detector is the
    //    primary wakeup mechanism; GPS is a fallback used when the accelerometer
    //    is unavailable or the phone is in a vehicle).  Accuracy gating is kept
    //    but relaxed to 60 % of combined radius so that balanced/lowPower fixes
    //    (±30–100 m) don't block detection of clear high-speed movement.
    //
    //  • ACTIVE mode (keep-active): loose guards so that normal walking pace
    //    (~1.5 m/s, ~10–15 m per 10 s interval) continuously refreshes
    //    [_lastMeaningfulMovementTime] and prevents the one-minute silence timer
    //    from firing mid-walk.  No accuracy gating — at active-mode precision
    //    the fix interval is short enough that genuine movement clearly exceeds
    //    the 10 m floor.

    final bool isClearlyMoving;

    if (_currentMode == AutoTrackingRuntimeMode.passive) {
      // Passive → active: stricter check (GPS wakeup fallback path).
      // Clamp speedAccuracyMps: some Android builds report -1 for "unknown";
      // subtracting a negative value would artificially inflate net speed.
      final combinedAccuracyMeters =
          (lastFix?.hAccuracyMeters ?? 0.0) + fix.hAccuracyMeters;
      final isDistanceConfident = distanceMeters >= activeWakeThresholdMeters &&
          distanceMeters > combinedAccuracyMeters * 0.6;
      final clampedSpeedAccuracy = math.max(0.0, fix.speedAccuracyMps);
      final netSpeedMps = math.max(0.0, fix.speedMps - clampedSpeedAccuracy);
      final isSpeedConfident = netSpeedMps >= activeWakeSpeedThresholdMps;
      isClearlyMoving = isSpeedConfident || isDistanceConfident;
    } else {
      // Active mode: loose check so walkers stay active.
      //
      // Speed accuracy can be reported as -1 on some Android builds (meaning
      // "unknown"). Clamping to 0 prevents the negative value from being
      // subtracted and artificially inflating net speed, which would otherwise
      // keep the device in active mode indefinitely while stationary.
      final clampedSpeedAccuracy = math.max(0.0, fix.speedAccuracyMps);
      final netSpeedMps = math.max(0.0, fix.speedMps - clampedSpeedAccuracy);
      final isSpeedConfident = netSpeedMps >= activeKeepSpeedThresholdMps;

      // Accuracy-gated distance check: the measured displacement must exceed
      // the combined horizontal-accuracy radius of both fixes.  Without this
      // gate, GPS drift while stationary (5–15 m is common with high-precision
      // fixes) can continuously refresh [_lastMeaningfulMovementTime] and
      // prevent the silence timer from ever switching to passive.
      final combinedAccuracyMeters =
          (lastFix?.hAccuracyMeters ?? 0.0) + fix.hAccuracyMeters;
      final effectiveDistanceThreshold =
          math.max(activeKeepDistanceMeters, combinedAccuracyMeters * 0.75);
      final isDistanceConfident = distanceMeters >= effectiveDistanceThreshold;

      isClearlyMoving = isSpeedConfident || isDistanceConfident;
    }

    _lastObservedFix = fix;

    if (isClearlyMoving) {
      _lastMeaningfulMovementTime = fix.timestampUtc;
      _currentMode = AutoTrackingRuntimeMode.active;
      return _currentMode;
    }

    final lastMovementTime = _lastMeaningfulMovementTime;
    if (lastMovementTime == null) {
      _lastMeaningfulMovementTime = fix.timestampUtc;
      return _currentMode;
    }

    final stillFor = fix.timestampUtc.difference(lastMovementTime);
    if (stillFor >= passiveAfterStillness) {
      _currentMode = AutoTrackingRuntimeMode.passive;
    }

    return _currentMode;
  }
}