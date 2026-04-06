
final class LocationFix {

  final double latitude;
  final double longitude;

  /// When the device/provider says this fix was measured (UTC).
  final DateTime timestampUtc;

  /// Estimated horizontal accuracy radius in meters (>= 0).
  final double hAccuracyMeters;

  /// Altitude above mean sea level in meters (if available).
  final double altitudeMeters;

  /// Estimated vertical accuracy in meters (if available).
  final double altitudeAccuracyMeters;

  /// Speed in meters per second (if available).
  final double speedMps;

  /// Speed accuracy in meters per second (if available).
  final double speedAccuracyMps;

  /// Heading/bearing in degrees (0..360) (if available).
  final double headingDegrees;

  /// Heading accuracy in degrees (if available).
  final double headingAccuracyDegrees;

  /// Provider/engine identifier (e.g. "gps", "network", "fused", "mock").
  /// A string so we don't leak platform enums into domain.
  final String? provider;

  /// Whether the fix is suspected/known to be mocked
  final bool? isMocked;

  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.timestampUtc,
    required this.hAccuracyMeters,
    required this.altitudeMeters,
    required this.altitudeAccuracyMeters,
    required this.speedMps,
    required this.speedAccuracyMps,
    required this.headingDegrees,
    required this.headingAccuracyDegrees,
    this.provider,
    this.isMocked,
  });

  /// Returns a copy with selective overrides (no mutable state).
  LocationFix copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestampUtc,
    double? hAccuracyMeters,
    double? altitudeMeters,
    double? altitudeAccuracyMeters,
    double? speedMps,
    double? speedAccuracyMps,
    double? headingDegrees,
    double? headingAccuracyDegrees,
    String? provider,
    bool? isMocked,
  }) {
    return LocationFix(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      hAccuracyMeters: hAccuracyMeters ?? this.hAccuracyMeters,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      altitudeAccuracyMeters:
      altitudeAccuracyMeters ?? this.altitudeAccuracyMeters,
      speedMps: speedMps ?? this.speedMps,
      speedAccuracyMps: speedAccuracyMps ?? this.speedAccuracyMps,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      headingAccuracyDegrees:
      headingAccuracyDegrees ?? this.headingAccuracyDegrees,
      provider: provider ?? this.provider,
      isMocked: isMocked ?? this.isMocked,
    );
  }

}