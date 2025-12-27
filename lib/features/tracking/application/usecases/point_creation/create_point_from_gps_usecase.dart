
import 'dart:async';

import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/result.dart';

final class CreatePointFromGpsUseCase {

  final TrackerSettingsService _trackerPreferencesService;
  final IHardwareRepository _hardwareInterfaces;

  CreatePointFromGpsUseCase(this._hardwareInterfaces);

  /// The method that handles manually creating a point or when automatic tracking has not tracked a cached point for too long.
  Future<Result<LocalPoint, String>> call() async {

    final DateTime pointCreationTimestamp = DateTime.now().toUtc();
    final Future<bool> isTrackingAutomaticallyF = _trackerPreferencesService.getAutomaticTrackingSetting();
    final Future<LocationAccuracy> accuracyF = _trackerPreferencesService.getLocationAccuracySetting();
    final Future<int> currentTrackingFrequencyF = _trackerPreferencesService.getTrackingFrequencySetting();

    final result = await Future.wait([
      isTrackingAutomaticallyF,
      accuracyF,
      currentTrackingFrequencyF
    ]);

    final bool isTrackingAutomatically = result[0] as bool;
    final LocationAccuracy accuracy = result[1] as LocationAccuracy;
    final int currentTrackingFrequency = result[2] as int;

    final Duration autoAttemptTimeout = _clampDuration(
      Duration(seconds: currentTrackingFrequency),
      const Duration(seconds: 5),
      const Duration(seconds: 30),
    );

    final Duration autoStaleMax = _clampDuration(
      Duration(seconds: currentTrackingFrequency * 2),
      const Duration(seconds: 5),
      const Duration(seconds: 30),
    );

    const Duration manualTimeout = Duration(seconds: 15);
    const Duration manualStaleMax = Duration(seconds: 90);

    final Duration attemptTimeout = isTrackingAutomatically ? autoAttemptTimeout : manualTimeout;
    final Duration staleMax = isTrackingAutomatically ? autoStaleMax : manualStaleMax;

    Result<Position, String> posResult;

    try {
      posResult = await _hardwareInterfaces
          .getPosition(accuracy)
          .timeout(attemptTimeout);
    } on TimeoutException {
      return Err("NO_FIX_TIMEOUT");
    } catch (e) {
      return Err("POSITION_ERROR: $e");
    }

    if (posResult case Err(value: final String error)) {
      return Err(error);
    }

    final Position position = posResult.unwrap();

    final DateTime nowUtc = DateTime.now().toUtc();
    final DateTime fixTs = position.timestamp.toUtc();

    final Duration age = nowUtc.difference(fixTs);
    if (age < Duration.zero || age > staleMax) {
      return Err("STALE_FIX: age=${age.inSeconds}s (max=${staleMax.inSeconds}s)");
    }

    final Result<LocalPoint, String> pointResult = await createPointFromPosition(position, pointCreationTimestamp);

    if (pointResult case Err()) {
      return pointResult;
    }

    Result<LocalPoint, String> finalResult = pointResult;


    final point = pointResult.unwrap();
    await autoStoreAndUpload(point);

    return finalResult;
  }

  Duration _clampDuration(Duration v, Duration min, Duration max) {
    if (v < min) {
      return min;
    }
    if (v > max) {
      return max;
    }
    return v;
  }
}