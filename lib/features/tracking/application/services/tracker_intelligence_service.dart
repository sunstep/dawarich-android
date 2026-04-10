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
  static const double activeWakeThresholdMeters = 25;
  static const double activeWakeSpeedThresholdMps = 2.0;

  AutoTrackingRuntimeMode get currentMode => _currentMode;
  DateTime? get lastMeaningfulMovementTime => _lastMeaningfulMovementTime;

  void reset() {
    _currentMode = AutoTrackingRuntimeMode.active;
    _lastMeaningfulMovementTime = null;
    _lastObservedFix = null;
    _isOnWifi = false;
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

    // ── Noise guards ──────────────────────────────────────────────────────────

    // Guard 1 — Accuracy-gated distance.
    // The displacement between two fixes must exceed the *combined* accuracy
    // radius of both endpoints, not just the raw travel threshold.  If the
    // device's GPS reported ±20 m for each fix the real position could be
    // anywhere within a 40 m bubble — a 30 m jump is indistinguishable from
    // noise and must not trigger a wake-up.
    //
    // [activeWakeThresholdMeters] is a minimum sensitivity floor (25 m), not
    // an accuracy ceiling.  At high / best precision (±5–10 m per fix) the
    // combined bubble is 10–20 m and the floor is the binding constraint.
    // At balanced / lowPower precision (±30–100 m per fix) the combined bubble
    // grows to 60–200 m and becomes the binding constraint instead — meaning
    // the check automatically loosens in proportion to the user's chosen
    // [LocationPrecision] without needing a separate user-facing setting and
    // without the risk of silently blocking all wake decisions that a hard
    // accuracy ceiling would introduce.
    final combinedAccuracyMeters =
        (lastFix?.hAccuracyMeters ?? 0.0) + fix.hAccuracyMeters;
    final isDistanceConfident = distanceMeters >= activeWakeThresholdMeters &&
        distanceMeters > combinedAccuracyMeters;

    // Guard 2 — Speed accuracy gating.
    // Subtract the provider's reported speed uncertainty before comparing so
    // that Doppler noise on a stationary receiver (which can read 1–3 m/s)
    // never crosses the threshold on its own.
    final netSpeedMps = math.max(0.0, fix.speedMps - fix.speedAccuracyMps);
    final isSpeedConfident = netSpeedMps >= activeWakeSpeedThresholdMps;

    final isClearlyMoving = isSpeedConfident || isDistanceConfident;

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