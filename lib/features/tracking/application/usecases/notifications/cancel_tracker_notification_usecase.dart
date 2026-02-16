import 'package:dawarich/features/tracking/application/services/tracking_notification_service.dart';

/// Hide the tracking notification (e.g., when stopping tracking).
final class CancelTrackerNotificationUseCase {
  final TrackerNotificationService _service;

  CancelTrackerNotificationUseCase(this._service);

  Future<void> call() => _service.cancelTracker();
}