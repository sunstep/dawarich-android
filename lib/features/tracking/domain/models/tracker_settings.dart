
import 'package:dawarich/features/tracking/domain/enum/location_precision.dart';

final class TrackerSettings {
  final int userId;
  final bool automaticTracking;
  final int trackingFrequency;
  final LocationPrecision locationPrecision;
  final int minimumPointDistance;
  final int pointsPerBatch;
  final String deviceId;

  const TrackerSettings({
    required this.userId,
    required this.automaticTracking,
    required this.trackingFrequency,
    required this.locationPrecision,
    required this.minimumPointDistance,
    required this.pointsPerBatch,
    required this.deviceId,
  });

  TrackerSettings copyWith({
    bool? automaticTracking,
    int? trackingFrequency,
    LocationPrecision? locationPrecision,
    int? minimumPointDistance,
    int? pointsPerBatch,
    String? deviceId
  }) {
    return TrackerSettings(
      userId: userId,
      automaticTracking: automaticTracking ?? this.automaticTracking,
      trackingFrequency: trackingFrequency ?? this.trackingFrequency,
      locationPrecision: locationPrecision ?? this.locationPrecision,
      minimumPointDistance: minimumPointDistance ?? this.minimumPointDistance,
      pointsPerBatch: pointsPerBatch ?? this.pointsPerBatch,
      deviceId: deviceId ?? this.deviceId
    );
  }
}