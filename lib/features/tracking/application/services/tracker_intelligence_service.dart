import 'dart:math' as math;

import 'package:dawarich/features/tracking/domain/enum/auto_tracking_runtime_mode.dart';
import 'package:dawarich/features/tracking/domain/enum/battery_state.dart';
import 'package:dawarich/features/tracking/domain/enum/connectivity_kind.dart';
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';


final class TrackerIntelligenceService {
  AutoTrackingRuntimeMode _currentMode = AutoTrackingRuntimeMode.active;
  DateTime? _lastMeaningfulMovementTime;
  LocationFix? _lastObservedFix;

  // Time we entered monitor mode, used for the idle timeout.
  DateTime? _monitorEnteredTime;

  // Whether we're currently on WiFi.
  bool _isOnWifi = false;

  // Tracks the previous charging state so we can detect the unplug transition.
  bool _wasCharging = false;

  // How long without meaningful movement in active mode before dropping to monitor.
  // Long enough to survive traffic lights, station stops, and brief tunnels.
  static const Duration activeToMonitorStillness = Duration(minutes: 3);

  // How long in monitor without confirmed movement before going passive.
  // Covers longer waits like level crossings or extended station stops.
  static const Duration monitorIdleTimeout = Duration(minutes: 5);

  // Passive mode runs a PRIORITY_NO_POWER piggyback stream as a free point
  // recorder alongside activity recognition. evaluateFix() is NOT called for
  // passive fixes in PointAutomationService — mode transitions from passive are
  // driven by activity recognition only. _evaluatePassive() is kept as a
  // defensive fallback in case that guard is ever removed.

  // Distance threshold for passive wake-up when speed isn't available.
  static const double passiveWakeDistanceMeters = 80;

  // Net speed (after subtracting speed accuracy) to wake passive to monitor.
  // Kept low because PRIORITY_LOW_POWER speed accuracy can be ±0.5–1.0 m/s.
  static const double passiveWakeSpeedMps = 0.5;

  // Vehicle-level speed that skips monitor entirely and goes straight to active.
  // ~18 km/h — unambiguously in a vehicle.
  static const double passiveDirectActiveSpeedMps = 5.0;

  // Speed at which a balanced fix (monitor mode) promotes to active.
  // 0.8 m/s net corresponds to about 1.1–1.3 m/s actual — a slow walk.
  static const double monitorPromoteSpeedMps = 0.8;

  // Minimum net speed to keep the movement timestamp refreshed while active.
  // Slightly lower than monitorPromoteSpeedMps so a small speed dip doesn't
  // immediately start the silence countdown.
  static const double activeKeepSpeedMps = 0.5;

  // Minimum displacement between consecutive active fixes to count as real movement.
  // Prevents GPS jitter (±5–15 m) from refreshing the timestamp when stationary.
  static const double activeKeepDistanceMeters = 20.0;

  // Counts consecutive zero-speed fixes in monitor mode for debug logging.
  // Some OEMs don't populate speed at PRIORITY_BALANCED.
  int _consecutiveZeroSpeedFixes = 0;

  AutoTrackingRuntimeMode get currentMode => _currentMode;
  DateTime? get lastMeaningfulMovementTime => _lastMeaningfulMovementTime;

  void reset() {
    _currentMode = AutoTrackingRuntimeMode.active;
    _lastMeaningfulMovementTime = null;
    _lastObservedFix = null;
    _monitorEnteredTime = null;
    _consecutiveZeroSpeedFixes = 0;
    _isOnWifi = false;
    _wasCharging = false;
  }

  /// Called when the OS delivers a locomotion transition event.
  ///
  /// If the tracker is in passive mode, it transitions to monitor so the
  /// cell+WiFi stream can confirm real movement before spinning up full GPS.
  /// If already in monitor or active, this is a no-op — evaluateFix() handles
  /// transitions from there.
  AutoTrackingRuntimeMode notifyMotionTransitionDetected() {
    if (kDebugMode) {
      debugPrint(
        '[TrackerIntelligence] Motion transition event received '
        '(current mode: $_currentMode)',
      );
    }

    if (_currentMode == AutoTrackingRuntimeMode.passive) {
      _lastMeaningfulMovementTime = null;
      _lastObservedFix = null;
      _setMode(AutoTrackingRuntimeMode.monitor);

      if (kDebugMode) {
        debugPrint(
          '[TrackerIntelligence] Motion transition detected → passive → monitor',
        );
      }
    } else {
      // Already in monitor or active — don't refresh the movement timestamp.
      // GPS fixes are the sole source of truth for the keep-alive. Letting
      // motion events refresh it caused the tracker to stay permanently active
      // because false-positive activity events (e.g. walking to the kitchen)
      // kept resetting the silence timer.
      if (kDebugMode) {
        debugPrint(
          '[TrackerIntelligence] Motion transition detected while $_currentMode '
          '— ignoring (GPS fixes manage the keep-alive in active/monitor).',
        );
      }
    }

    return _currentMode;
  }

  /// Called whenever the network connectivity changes.
  ///
  /// WiFi connected: if we're in active mode, drop to monitor so low-power GPS
  /// can check whether we're actually stationary. Going straight to passive on
  /// WiFi connect would interrupt tracking on public hotspots or transport WiFi.
  /// Monitor will naturally fall through to passive via the idle timeout if
  /// nothing is moving.
  ///
  /// WiFi lost: move to monitor so GPS can quickly evaluate if we're moving.
  AutoTrackingRuntimeMode notifyConnectivityChanged(ConnectivityKind kind) {
    final wasOnWifi = _isOnWifi;
    _isOnWifi = kind == ConnectivityKind.wifi;

    if (_isOnWifi && !wasOnWifi) {
      // Only drop to monitor if we're in active — no need to restart from
      // passive or monitor since they're already lower power.
      if (_currentMode == AutoTrackingRuntimeMode.active) {
        _lastMeaningfulMovementTime = null;
        _lastObservedFix = null;
        _setMode(AutoTrackingRuntimeMode.monitor);
      }
    } else if (!_isOnWifi && wasOnWifi) {
      _lastMeaningfulMovementTime = null;
      _lastObservedFix = null;
      _setMode(AutoTrackingRuntimeMode.monitor);
    }

    return _currentMode;
  }

  /// Called whenever the battery/charging state changes.
  ///
  /// Charger unplugged while in passive mode wakes the tracker to monitor.
  /// It's a free signal that the user may be about to leave — pulling the
  /// phone off the charger before heading out. Monitor will then confirm
  /// whether actual movement follows.
  AutoTrackingRuntimeMode notifyBatteryStateChanged(BatteryState state) {
    final wasCharging = _wasCharging;
    _wasCharging = state == BatteryState.charging ||
        state == BatteryState.full ||
        state == BatteryState.connectedNotCharging;

    final justUnplugged = wasCharging && state == BatteryState.discharging;

    if (justUnplugged && _currentMode == AutoTrackingRuntimeMode.passive) {
      _lastMeaningfulMovementTime = null;
      _lastObservedFix = null;
      _setMode(AutoTrackingRuntimeMode.monitor);
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

    // Some Android builds report -1 for unknown speed accuracy — clamp to 0.
    final clampedSpeedAccuracy = math.max(0.0, fix.speedAccuracyMps);
    final netSpeedMps = math.max(0.0, fix.speedMps - clampedSpeedAccuracy);
    final combinedAccuracyMeters =
        (lastFix?.hAccuracyMeters ?? 0.0) + fix.hAccuracyMeters;

    _lastObservedFix = fix;

    switch (_currentMode) {
      case AutoTrackingRuntimeMode.passive:
        // Passive has no stream — this branch shouldn't be reached normally.
        return _evaluatePassive(fix, distanceMeters, netSpeedMps);
      case AutoTrackingRuntimeMode.monitor:
        return _evaluateMonitor(fix, distanceMeters, netSpeedMps, combinedAccuracyMeters);
      case AutoTrackingRuntimeMode.active:
        return _evaluateActive(fix, distanceMeters, netSpeedMps, combinedAccuracyMeters);
    }
  }

  AutoTrackingRuntimeMode _evaluatePassive(
    LocationFix fix,
    double distanceMeters,
    double netSpeedMps,
  ) {
    // Vehicle speed — skip monitor and go straight to active.
    if (netSpeedMps >= passiveDirectActiveSpeedMps) {
      if (kDebugMode) {
        debugPrint(
          '[TrackerIntelligence] Passive → active (vehicle speed: '
          '${netSpeedMps.toStringAsFixed(1)} m/s >= $passiveDirectActiveSpeedMps)',
        );
      }
      _lastMeaningfulMovementTime = fix.timestampUtc;
      _setMode(AutoTrackingRuntimeMode.active);
      return _currentMode;
    }

    final isSpeedSignificant = netSpeedMps >= passiveWakeSpeedMps;
    final isDistanceSignificant = distanceMeters >= passiveWakeDistanceMeters;

    if (isSpeedSignificant || isDistanceSignificant) {
      if (kDebugMode) {
        debugPrint(
          '[TrackerIntelligence] Passive → monitor (location fix fallback: '
          'speed=${netSpeedMps.toStringAsFixed(1)} m/s, '
          'distance=${distanceMeters.toStringAsFixed(0)} m)',
        );
      }
      _lastMeaningfulMovementTime = fix.timestampUtc;
      _setMode(AutoTrackingRuntimeMode.monitor);
    }

    return _currentMode;
  }

  AutoTrackingRuntimeMode _evaluateMonitor(
    LocationFix fix,
    double distanceMeters,
    double netSpeedMps,
    double combinedAccuracy,
  ) {
    if (fix.speedMps <= 0.0) {
      _consecutiveZeroSpeedFixes++;
    } else {
      _consecutiveZeroSpeedFixes = 0;
    }

    if (kDebugMode && _consecutiveZeroSpeedFixes > 0) {
      debugPrint(
        '[TrackerIntelligence] Monitor: $_consecutiveZeroSpeedFixes consecutive '
        'zero-speed fixes (OEM may not populate speed at PRIORITY_BALANCED)',
      );
    }

    if (netSpeedMps >= monitorPromoteSpeedMps) {
      if (kDebugMode) {
        debugPrint(
          '[TrackerIntelligence] Monitor → active (speed: '
          '${netSpeedMps.toStringAsFixed(1)} m/s >= $monitorPromoteSpeedMps)',
        );
      }
      _consecutiveZeroSpeedFixes = 0;
      _lastMeaningfulMovementTime = fix.timestampUtc;
      _setMode(AutoTrackingRuntimeMode.active);
      return _currentMode;
    }

    // Safety net for when the external monitor idle timer is delayed by doze mode.
    final enteredTime = _monitorEnteredTime;
    if (enteredTime != null) {
      final timeInMonitor = fix.timestampUtc.difference(enteredTime);
      if (timeInMonitor >= monitorIdleTimeout) {
        _setMode(AutoTrackingRuntimeMode.passive);
        return _currentMode;
      }
    }

    return _currentMode;
  }

  AutoTrackingRuntimeMode _evaluateActive(
    LocationFix fix,
    double distanceMeters,
    double netSpeedMps,
    double combinedAccuracy,
  ) {
    // Displacement must exceed the total positional uncertainty (sum of both
    // error radii) before it counts as real movement, to avoid GPS jitter
    // refreshing the timestamp when stationary.
    final effectiveDistanceThreshold =
        math.max(activeKeepDistanceMeters, combinedAccuracy * 1.0);
    final isDistanceConfident = distanceMeters >= effectiveDistanceThreshold;
    final isSpeedConfident = netSpeedMps >= activeKeepSpeedMps;

    if (isDistanceConfident || isSpeedConfident) {
      _lastMeaningfulMovementTime = fix.timestampUtc;
      return _currentMode;
    }

    final lastMovementTime = _lastMeaningfulMovementTime;
    if (lastMovementTime == null) {
      _lastMeaningfulMovementTime = fix.timestampUtc;
      return _currentMode;
    }

    final stillFor = fix.timestampUtc.difference(lastMovementTime);
    if (stillFor >= activeToMonitorStillness) {
      _setMode(AutoTrackingRuntimeMode.monitor);
    }

    return _currentMode;
  }

  /// Force the service into [mode] without GPS evaluation. Called by the
  /// external silence/idle timers in PointAutomationService to keep this
  /// service in sync when a mode change is timer-driven rather than fix-driven.
  ///
  /// Also resets [_lastObservedFix] so the next fix from the new accuracy class
  /// isn't compared against a stale fix from a different class.
  void forceMode(AutoTrackingRuntimeMode mode) {
    _setMode(mode);
    _lastObservedFix = null;
  }

  void _setMode(AutoTrackingRuntimeMode mode) {
    if (_currentMode == mode) return;
    _currentMode = mode;

    if (mode == AutoTrackingRuntimeMode.monitor) {
      _monitorEnteredTime = DateTime.now().toUtc();
      _consecutiveZeroSpeedFixes = 0;
    } else {
      _monitorEnteredTime = null;
      _consecutiveZeroSpeedFixes = 0;
    }
  }
}