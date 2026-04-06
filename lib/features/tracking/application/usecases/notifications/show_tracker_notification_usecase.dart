import 'package:dawarich/features/tracking/application/services/tracking_notification_service.dart';

final class ShowTrackerNotificationUseCase {
  final TrackerNotificationService _service;

  ShowTrackerNotificationUseCase(this._service);

  Future<void> call({
    required String title,
    required String body,
    String? payload,
  }) {
    return _service.showTracker(
      title: title,
      body: body,
      payload: payload ?? '/tracker',
    );
  }
}