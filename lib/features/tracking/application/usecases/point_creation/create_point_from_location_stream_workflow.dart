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
import 'package:option_result/result.dart';

/// Workflow for creating points using timer-based polling with cached locations.
/// Uses our own timer for precise frequency control, combined with location
/// stream to keep a fresh cached location ready.
final class CreatePointFromLocationStreamWorkflow {
  final GetTrackerSettingsUseCase _getTrackerSettings;
  final ILocationProvider _locationProvider;
  final CreatePointUseCase _createPointFromLocationFix;

  CreatePointFromLocationStreamWorkflow(
    this._getTrackerSettings,
    this._locationProvider,
    this._createPointFromLocationFix,
  );

  /// Returns a stream of location points at precise intervals based on user settings.
  /// Uses a timer for exact frequency control rather than relying on OS-level intervals.
  Stream<Result<LocalPoint, String>> getPointStream(int userId) async* {
    if (kDebugMode) {
      debugPrint('[LocationStream] Starting location stream for user $userId');
    }

    final TrackerSettings settings = await _getTrackerSettings(userId);
    final LocationPrecision accuracy = settings.locationPrecision;
    final int trackingFrequencySeconds = settings.trackingFrequency;

    if (kDebugMode) {
      debugPrint('[LocationStream] Settings: accuracy=$accuracy, frequency=${trackingFrequencySeconds}s');
    }

    LocationFix? latestFix;
    StreamSubscription<LocationFix>? locationSub;

    final LocationRequest request = LocationRequest(
      precision: accuracy,
      distanceFilterMeters: 0,
      timeLimit: null,
      intervalDuration: const Duration(seconds: 1),
    );

    try {
      final Stream<LocationFix> locationStream = _locationProvider.getLocationStream(request);
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

      if (kDebugMode) {
        debugPrint('[LocationStream] Getting initial position...');
      }
      final initialResult = await _locationProvider.getCurrent(request);
      if (initialResult case Ok(value: final fix)) {
        latestFix = fix;
        final timestamp = DateTime.now().toUtc();
        final pointResult = await _createPointFromLocationFix(fix, timestamp, userId);
        if (pointResult case Ok(value: final point)) {
          yield Ok(point);
        }
      }

      Timer.periodic(Duration(seconds: trackingFrequencySeconds), (timer) async {
        if (controller.isClosed) {
          timer.cancel();
          return;
        }

        if (kDebugMode) {
          debugPrint('[LocationStream] Timer tick - creating point');
        }

        LocationFix? fixToUse = latestFix;

        if (fixToUse == null ||
            DateTime.now().difference(fixToUse.timestampUtc).inSeconds > 30) {
          if (kDebugMode) {
            debugPrint('[LocationStream] Cache stale or empty, fetching current position');
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
        debugPrint('[LocationStream] Error in location stream: $e\n$s');
      }
      yield Err('Location stream error: $e');
      await locationSub?.cancel();
    }

    if (kDebugMode) {
      debugPrint('[LocationStream] Location stream ended');
    }
  }
}
