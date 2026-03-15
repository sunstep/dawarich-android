import 'dart:async';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/repositories/location_provider_interface.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/get_tracker_settings_usecase.dart';
import 'package:dawarich/features/tracking/domain/enum/location_precision.dart';
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:dawarich/features/tracking/domain/models/location_request.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/result.dart';

/// Workflow for creating points using either:
/// - Auto mode (0): Event-driven tracking when location changes meaningfully
/// - Timer mode (>0): Fixed interval tracking
final class CreatePointFromLocationStreamWorkflow {

  final GetTrackerSettingsUseCase _getTrackerSettings;
  final ILocationProvider _locationProvider;
  final CreatePointUseCase _createPointFromLocationFix;

  CreatePointFromLocationStreamWorkflow(
    this._getTrackerSettings,
    this._locationProvider,
    this._createPointFromLocationFix,
  );

  /// Returns a stream of location points based on user settings.
  Stream<Result<LocalPoint, String>> getPointStream(int userId) async* {
    if (kDebugMode) {
      debugPrint('[LocationStream] Starting location stream for user $userId');
    }

    final TrackerSettings settings = await _getTrackerSettings(userId);
    final LocationPrecision precision = settings.locationPrecision;
    final int trackingFrequencySeconds = settings.trackingFrequency;
    final int minimumDistance = settings.minimumPointDistance;
    final bool isAutoMode = trackingFrequencySeconds == 0;

    if (kDebugMode) {
      debugPrint('[LocationStream] Settings: precision=$precision, frequency=${trackingFrequencySeconds}s, minDistance=${minimumDistance}m, autoMode=$isAutoMode');
    }

    if (isAutoMode) {
      yield* _getAutoModePointStream(userId, precision, minimumDistance);
    } else {
      yield* _getTimerPointStream(userId, precision, minimumDistance, trackingFrequencySeconds);
    }

    if (kDebugMode) {
      debugPrint('[LocationStream] Location stream ended');
    }
  }

  Duration _getAutoModeInterval(
      LocationPrecision precision,
      int minimumDistance,
      ) {
    if (minimumDistance >= 100) {
      return const Duration(seconds: 30);
    }

    return switch (precision) {
      LocationPrecision.best => const Duration(seconds: 10),
      LocationPrecision.high => const Duration(seconds: 10),
      LocationPrecision.balanced => const Duration(seconds: 15),
      LocationPrecision.lowPower => const Duration(seconds: 30),
    };
  }

  /// Auto mode: track when the device has moved a meaningful distance.
  /// Uses user's minimum distance if set, otherwise derives from precision setting.
  Stream<Result<LocalPoint, String>> _getAutoModePointStream(
    int userId,
    LocationPrecision precision,
    int minimumDistance,
  ) async* {

    final int distanceFilter = minimumDistance > 0
        ? minimumDistance
        : switch (precision) {
            LocationPrecision.best => 10,
            LocationPrecision.high => 10,
            LocationPrecision.balanced => 25,
            LocationPrecision.lowPower => 50,
          };

    final autoInterval = _getAutoModeInterval(precision, minimumDistance);

    final request = LocationRequest(
      precision: precision,
      distanceFilterMeters: distanceFilter,
      timeLimit: null,
      intervalDuration: autoInterval,
    );

    if (kDebugMode) {
      debugPrint(
        '[LocationStream] Auto mode: distance filter = ${distanceFilter}m, '
            'interval = ${autoInterval.inSeconds}s',
      );
    }

    LocationFix? lastRecordedFix;
    bool isFirstPoint = true;

    try {
      // Listen to location stream, first emission becomes the initial point
      final locationStream = _locationProvider.getLocationStream(request);

      await for (final fix in locationStream) {
        if (isFirstPoint) {
          isFirstPoint = false;
          lastRecordedFix = fix;

          if (kDebugMode) {
            debugPrint('[LocationStream] Auto: Recording initial location');
          }

          final timestamp = DateTime.now().toUtc();
          final pointResult = await _createPointFromLocationFix(fix, timestamp, userId);

          if (pointResult case Ok(value: final point)) {
            yield Ok(point);
          }
          continue;
        }

        // Subsequent points are filtered
        if (_shouldRecordPoint(lastRecordedFix, fix, distanceFilter)) {
          if (kDebugMode) {
            debugPrint('[LocationStream] Auto: Recording new location');
          }

          final timestamp = DateTime.now().toUtc();
          final pointResult = await _createPointFromLocationFix(fix, timestamp, userId);

          if (pointResult case Ok(value: final point)) {
            lastRecordedFix = fix;
            yield Ok(point);
          } else if (pointResult case Err(value: final err)) {
            if (kDebugMode) {
              debugPrint('[LocationStream] Point creation failed: $err');
            }
          }
        } else if (kDebugMode) {
          debugPrint('[LocationStream] Auto: Skipping similar location');
        }
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[LocationStream] Auto mode error: $e\n$s');
      }
      yield Err('Location stream error: $e');
    }
  }

  /// Check if we should record this point (new location or periodic stationary update).
  bool _shouldRecordPoint(LocationFix? last, LocationFix current, int minDistMeters) {
    if (last == null) {
      return true;
    }

    final dist = Geolocator.distanceBetween(last.latitude, last.longitude, current.latitude, current.longitude);
    if (dist >= minDistMeters) {
      return true;
    }

    final timeDiff = current.timestampUtc.difference(last.timestampUtc).inSeconds;
    return timeDiff > 60;
  }

  /// Timer mode: emit points at fixed intervals using cached location.
  Stream<Result<LocalPoint, String>> _getTimerPointStream(
      int userId,
      LocationPrecision precision,
      int minimumDistance,
      int frequencySeconds,
      ) async* {
    LocationFix? latestFix;
    StreamSubscription<LocationFix>? locationSub;
    Timer? periodicTimer;
    final controller = StreamController<Result<LocalPoint, String>>();

    final int minSeconds = 1;
    final int intervalSeconds =
    (frequencySeconds / 2).ceil().clamp(minSeconds, frequencySeconds);

    final intervalDuration = Duration(seconds: intervalSeconds);
    final staleMax = _getTimerModeStaleMax(frequencySeconds);

    final request = LocationRequest(
      precision: precision,
      distanceFilterMeters: minimumDistance,
      timeLimit: null,
      intervalDuration: intervalDuration,
    );

    try {
      final locationStream = _locationProvider.getLocationStream(request);
      locationSub = locationStream.listen(
            (fix) {
          latestFix = fix;
          if (kDebugMode) {
            debugPrint('[LocationStream] Cache updated: ${fix.latitude}, ${fix.longitude}');
          }
        },
        onError: (e) {
          if (kDebugMode) {
            debugPrint('[LocationStream] Stream error: $e');
          }
        },
      );

      final initialResult = await _locationProvider.getCurrent(request);
      if (initialResult case Ok(value: final fix)) {
        latestFix = fix;
        final timestamp = DateTime.now().toUtc();
        final pointResult = await _createPointFromLocationFix(fix, timestamp, userId);
        if (pointResult case Ok(value: final point)) {
          controller.add(Ok(point));
        } else if (pointResult case Err(value: final err)) {
          controller.add(Err('Failed to create initial point: $err'));
        }
      }

      final timerDuration = Duration(seconds: frequencySeconds);

      if (kDebugMode) {
        debugPrint(
          '[LocationStream] Timer mode: interval = ${frequencySeconds}s, '
              'staleMax = ${staleMax.inSeconds}s',
        );
      }

      periodicTimer = Timer.periodic(timerDuration, (timer) async {
        if (controller.isClosed) {
          timer.cancel();
          return;
        }

        final fixToUse = latestFix;

        if (fixToUse == null) {
          if (kDebugMode) {
            debugPrint('[LocationStream] No cached fix yet, skipping timer tick');
          }
          controller.add(const Err('No cached location available'));
          return;
        }

        final age = DateTime.now().toUtc().difference(fixToUse.timestampUtc);

        if (age < Duration.zero || age > staleMax) {
          if (kDebugMode) {
            debugPrint(
              '[LocationStream] Cached fix too stale for timer tick '
                  '(age: ${age.inSeconds}s, max: ${staleMax.inSeconds}s), skipping',
            );
          }
          controller.add(Err('Cached location too stale (age: ${age.inSeconds}s)'));
          return;
        }

        try {
          final timestamp = DateTime.now().toUtc();
          final pointResult = await _createPointFromLocationFix(
            fixToUse,
            timestamp,
            userId,
          );

          if (pointResult case Ok(value: final point)) {
            controller.add(Ok(point));
          } else if (pointResult case Err(value: final err)) {
            if (kDebugMode) {
              debugPrint('[LocationStream] Point validation failed: $err');
            }
            controller.add(Err('Failed to create point: $err'));
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[LocationStream] Error creating point: $e');
          }
          controller.add(Err('Failed to create point: $e'));
        }
      });

      yield* controller.stream;
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[LocationStream] Timer error: $e\n$s');
      }
      yield Err('Location stream error: $e');
    } finally {
      periodicTimer?.cancel();
      await locationSub?.cancel();
      await controller.close();
    }
  }

  Duration _getTimerModeStaleMax(int frequencySeconds) {
    return Duration(
      seconds: (frequencySeconds * 2).clamp(30, 300),
    );
  }
}
