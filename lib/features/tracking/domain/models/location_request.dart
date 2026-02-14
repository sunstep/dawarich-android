
import 'package:dawarich/features/tracking/domain/enum/location_precision.dart';

final class LocationRequest {
  final LocationPrecision precision;

  /// Minimum distance (meters) before emitting a new fix.
  /// Null = provider default.
  final int? distanceFilterMeters;

  /// Provider-side timeout hint. Null = no hint.
  /// Your workflow can still enforce its own timeout via `.timeout(...)`.
  final Duration? timeLimit;

  /// Desired interval between location updates for streaming.
  /// This tells the OS how often we want to receive updates.
  /// Null = OS decides (can be very inconsistent).
  final Duration? intervalDuration;

  const LocationRequest({
    required this.precision,
    this.distanceFilterMeters,
    this.timeLimit,
    this.intervalDuration,
  });

  LocationRequest copyWith({
    LocationPrecision? precision,
    int? distanceFilterMeters,
    Duration? timeLimit,
    Duration? intervalDuration,
  }) {
    return LocationRequest(
      precision: precision ?? this.precision,
      distanceFilterMeters: distanceFilterMeters ?? this.distanceFilterMeters,
      timeLimit: timeLimit ?? this.timeLimit,
      intervalDuration: intervalDuration ?? this.intervalDuration,
    );
  }
}