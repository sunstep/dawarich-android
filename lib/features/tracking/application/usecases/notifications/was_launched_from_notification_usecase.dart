import 'package:dawarich/features/tracking/application/services/tracking_notification_service.dart';

final class WasLaunchedFromNotificationUseCase {
  final TrackerNotificationService _service;

  WasLaunchedFromNotificationUseCase(this._service);

  Future<bool> call() async {
    final d = await _service.getLaunchDetails();
    return d?.didNotificationLaunchApp == true;
  }
}