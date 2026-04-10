import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Uses the device's linear accelerometer (gravity-removed) to detect
/// sustained physical motion without requiring the GPS to run.
///
/// Battery cost is ~0.5–1 mA on modern devices compared with ~70–150 mA for
/// active GPS.  The detector is intended to be running while the tracker is
/// in passive mode so that the GPS can be woken up as soon as real movement
/// is confirmed, rather than waiting for the next scheduled passive-mode fix.
///
/// ── Algorithm ────────────────────────────────────────────────────────────────
/// Samples arrive from [userAccelerometerEventStream] at [_samplingPeriod]
/// (1 s → 1 Hz).  The magnitude of each (x, y, z) linear-acceleration
/// vector is pushed into a sliding window of [_windowSize] samples (~4 s).
/// When at least [_windowHits] of those samples exceed [motionThresholdMs2],
/// a motion event is emitted on [motionStream] and further events are
/// suppressed for [_cooldown] to avoid a flood of callbacks.
///
/// ── Why 1 Hz instead of 4 Hz ─────────────────────────────────────────────────
/// The higher 4 Hz rate kept the background-service Dart isolate processing
/// sensor events every 250 ms continuously.  This created significant Dart VM
/// scheduling pressure and GC churn that, after hours of overnight tracking,
/// caused the main-app isolate to stall during engine initialisation on the
/// next launch.  1 Hz is sufficient to detect walking within ~4 s (one full
/// window) while reducing Dart VM activity by 4×.
///
/// ── Threshold guidance ───────────────────────────────────────────────────────
/// Walking produces ~1–3 m/s² linear acceleration; a phone lying still on a
/// desk typically reads < 0.3 m/s².  [motionThresholdMs2] = 1.5 m/s² sits
/// comfortably between the two, catching walking while ignoring hand tremor
/// or vibration from a parked car's engine.
final class MotionDetectorService {
  /// Net linear-acceleration magnitude (m/s²) that counts as a "moving" sample.
  static const double motionThresholdMs2 = 1.5;

  /// How often the accelerometer is sampled (1 Hz — see class doc above).
  static const Duration _samplingPeriod = Duration(seconds: 1);

  /// Number of samples in the sliding window (~4 s at 1 Hz).
  static const int _windowSize = 4;

  /// Minimum number of above-threshold samples in the window to fire an event.
  static const int _windowHits = 2;

  /// Minimum time between consecutive motion events.
  static const Duration _cooldown = Duration(seconds: 10);

  final StreamController<void> _controller =
      StreamController<void>.broadcast();

  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  final List<double> _window = [];
  DateTime? _lastFired;

  /// Emits `void` whenever sustained motion is detected.
  Stream<void> get motionStream => _controller.stream;

  /// Starts listening to the accelerometer.  Safe to call multiple times —
  /// any existing subscription is cancelled first.
  void start() {
    _accelSub?.cancel();
    _window.clear();
    _lastFired = null;

    _accelSub = userAccelerometerEventStream(
      samplingPeriod: _samplingPeriod,
    ).listen(
      _onSample,
      onError: (Object e) {
        debugPrint('[MotionDetector] Accelerometer error: $e');
      },
    );

    if (kDebugMode) {
      debugPrint('[MotionDetector] Started.');
    }
  }

  /// Stops the accelerometer subscription.
  void stop() {
    _accelSub?.cancel();
    _accelSub = null;
    _window.clear();

    if (kDebugMode) {
      debugPrint('[MotionDetector] Stopped.');
    }
  }

  void dispose() {
    stop();
    _controller.close();
  }

  void _onSample(UserAccelerometerEvent event) {
    final magnitude =
        math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    _window.add(magnitude);
    if (_window.length > _windowSize) {
      _window.removeAt(0);
    }

    if (_window.length < _windowSize) return;

    final hits = _window.where((m) => m >= motionThresholdMs2).length;
    if (hits < _windowHits) return;

    final now = DateTime.now();
    final last = _lastFired;
    if (last != null && now.difference(last) < _cooldown) return;

    _lastFired = now;

    if (kDebugMode) {
      debugPrint(
        '[MotionDetector] Motion detected '
        '($hits/$_windowSize samples ≥ $motionThresholdMs2 m/s²).',
      );
    }

    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }
}


