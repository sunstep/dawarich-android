
import 'package:dawarich/features/tracking/domain/enum/location_precision.dart';

final class LocationRequest {
  final LocationPrecision precision;

  /// Minimum distance (meters) before emitting a new fix.
  /// Null = provider default.
  final int? distanceFilterMeters;

  /// Provider-side timeout hint. Null = no hint.
  /// Your workflow can still enforce its own timeout via `.timeout(...)`.
  final Duration? timeLimit;

  const LocationRequest({
    required this.precision,
    this.distanceFilterMeters,
    this.timeLimit,
  });

  LocationRequest copyWith({
    LocationPrecision? precision,
    int? distanceFilterMeters,
    Duration? timeLimit,
  }) {
    return LocationRequest(
      precision: precision ?? this.precision,
      distanceFilterMeters: distanceFilterMeters ?? this.distanceFilterMeters,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }
}