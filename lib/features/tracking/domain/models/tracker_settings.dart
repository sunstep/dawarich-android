
import 'package:geolocator/geolocator.dart';

final class TrackerSettings {
  final int userId;
  final bool automaticTracking;
  final int trackingFrequency;
  final LocationAccuracy locationAccuracy;
  final int minimumPointDistance;
  final int pointsPerBatch;
  final String deviceId;

  const TrackerSettings({
    required this.userId,
    required this.automaticTracking,
    required this.trackingFrequency,
    required this.locationAccuracy,
    required this.minimumPointDistance,
    required this.pointsPerBatch,
    required this.deviceId,
  });

  TrackerSettings copyWith({
    bool? automaticTracking,
    int? trackingFrequency,
    LocationAccuracy? locationAccuracy,
    int? minimumPointDistance,
    int? pointsPerBatch,
    String? deviceId
  }) {
    return TrackerSettings(
      userId: userId,
      automaticTracking: automaticTracking ?? this.automaticTracking,
      trackingFrequency: trackingFrequency ?? this.trackingFrequency,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      minimumPointDistance: minimumPointDistance ?? this.minimumPointDistance,
      pointsPerBatch: pointsPerBatch ?? this.pointsPerBatch,
      deviceId: deviceId ?? this.deviceId
    );
  }
}