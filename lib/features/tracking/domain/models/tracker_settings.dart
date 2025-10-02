
final class TrackerSettings {
  final bool? automaticTracking;
  final int? trackingFrequency;
  final int? locationAccuracy;
  final int? minimumPointDistance;
  final int? pointsPerBatch;
  final String? deviceId;

  const TrackerSettings({
    required this.automaticTracking,
    required this.trackingFrequency,
    required this.locationAccuracy,
    required this.minimumPointDistance,
    required this.pointsPerBatch,
    required this.deviceId,
  });
}