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
    double distanceMeters = 0;

    final lastFix = _lastObservedFix;
    if (lastFix != null) {
      distanceMeters = Geolocator.distanceBetween(
        lastFix.latitude,
        lastFix.longitude,
        fix.latitude,
        fix.longitude,
      );
    }

    final isClearlyMoving =
        distanceMeters >= activeWakeThresholdMeters ||
            fix.speedMps >= activeWakeSpeedThresholdMps;

    if (isClearlyMoving) {
      _lastMeaningfulMovementTime = fix.timestampUtc;
      _lastObservedFix = fix;
      _currentMode = AutoTrackingRuntimeMode.active;
      return _currentMode;
    }

    final lastMovementTime = _lastMeaningfulMovementTime;
    if (lastMovementTime == null) {
      _lastMeaningfulMovementTime = fix.timestampUtc;
      _lastObservedFix = fix;
      return _currentMode;
    }

    final stillFor = fix.timestampUtc.difference(lastMovementTime);
    if (stillFor >= passiveAfterStillness) {
      _currentMode = AutoTrackingRuntimeMode.passive;
    }

    _lastObservedFix = fix;
    return _currentMode;
  }
}