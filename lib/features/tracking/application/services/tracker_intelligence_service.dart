import 'dart:math' as math;

import 'package:dawarich/features/tracking/domain/enum/auto_tracking_runtime_mode.dart';
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:geolocator/geolocator.dart';


final class TrackerIntelligenceService {
  AutoTrackingRuntimeMode _currentMode = AutoTrackingRuntimeMode.active;
  DateTime? _lastMeaningfulMovementTime;
  LocationFix? _lastObservedFix;

  static const Duration passiveAfterStillness = Duration(minutes: 1);
  static const double activeWakeThresholdMeters = 25;
  static const double activeWakeSpeedThresholdMps = 2.0;

  AutoTrackingRuntimeMode get currentMode => _currentMode;
  DateTime? get lastMeaningfulMovementTime => _lastMeaningfulMovementTime;

  void reset() {
    _currentMode = AutoTrackingRuntimeMode.active;
    _lastMeaningfulMovementTime = null;
    _lastObservedFix = null;
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