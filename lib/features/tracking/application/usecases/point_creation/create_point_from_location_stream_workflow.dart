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
      yield* _getTimerPointStream(userId, precision, trackingFrequencySeconds);
    }

    if (kDebugMode) {
      debugPrint('[LocationStream] Location stream ended');
    }
  }

  /// Auto mode: track when the device has moved a meaningful distance.
  /// Uses user's minimum distance if set, otherwise derives from precision setting.
  Stream<Result<LocalPoint, String>> _getAutoModePointStream(
    int userId,
    LocationPrecision precision,
    int minimumDistance,
  ) async* {
    // Hybrid approach:
    // - If user set a minimum distance, use that (they know what's meaningful to them)
    // - Otherwise, derive from precision (reflects user's tracking mindset)
    final int distanceFilter = minimumDistance > 0
        ? minimumDistance
        : switch (precision) {
            LocationPrecision.best => 5,
            LocationPrecision.high => 5,
            LocationPrecision.balanced => 10,
            LocationPrecision.lowPower => 25,
          };

    final request = LocationRequest(
      precision: precision,
      distanceFilterMeters: distanceFilter,
      timeLimit: null,
      intervalDuration: const Duration(milliseconds: 500),
    );

    if (kDebugMode) {
      debugPrint('[LocationStream] Auto mode: distance filter = ${distanceFilter}m');
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
    int frequencySeconds,
  ) async* {
    LocationFix? latestFix;
    StreamSubscription<LocationFix>? locationSub;

    final request = LocationRequest(
      precision: precision,
      distanceFilterMeters: 0,
      timeLimit: null,
      intervalDuration: const Duration(seconds: 1),
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

      final controller = StreamController<Result<LocalPoint, String>>();

      final initialResult = await _locationProvider.getCurrent(request);
      if (initialResult case Ok(value: final fix)) {
        latestFix = fix;
        final timestamp = DateTime.now().toUtc();
        final pointResult = await _createPointFromLocationFix(fix, timestamp, userId);
        if (pointResult case Ok(value: final point)) {
          yield Ok(point);
        }
      }

      final timerDuration = Duration(seconds: frequencySeconds);

      if (kDebugMode) {
        debugPrint('[LocationStream] Timer mode: interval = ${frequencySeconds}s');
      }

      Timer.periodic(timerDuration, (timer) async {
        if (controller.isClosed) {
          timer.cancel();
          return;
        }

        LocationFix? fixToUse = latestFix;

        if (fixToUse == null ||
            DateTime.now().difference(fixToUse.timestampUtc).inSeconds > 30) {
          if (kDebugMode) {
            debugPrint('[LocationStream] Cache stale, fetching current position');
          }
          final currentResult = await _locationProvider.getCurrent(request);
          if (currentResult case Ok(value: final fix)) {
            fixToUse = fix;
            latestFix = fix;
          }
        }

        if (fixToUse == null) {
          controller.add(Err('No location available'));
          return;
        }

        try {
          final timestamp = DateTime.now().toUtc();
          final pointResult = await _createPointFromLocationFix(fixToUse, timestamp, userId);

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

      await for (final result in controller.stream) {
        yield result;
      }

      await locationSub.cancel();
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[LocationStream] Timer error: $e\n$s');
      }
      yield Err('Location stream error: $e');
      await locationSub?.cancel();
    }
  }
}
