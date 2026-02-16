import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/features/tracking/application/services/tracking_notification_service.dart';
import 'package:dawarich/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class InitializeTrackerNotificationServiceUseCase {
  final TrackerNotificationService _service;

  InitializeTrackerNotificationServiceUseCase(this._service);

  static String? pendingNotificationRoute;

  Future<void> call() async {
    await _service.init(
      onTap: (NotificationResponse response) {
        final payload = response.payload;
        if (payload == null) {
          return;
        }

        if (kDebugMode) {
          debugPrint('[NotificationService] tapped payload: $payload');
        }

        final route = AppRouter.routeFromPath(payload);
        appRouter.push(route);
      },
    );

    final launchDetails = await _service.getLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null) {
        pendingNotificationRoute = payload;
      }
    }
  }

  static void clearPendingRoute() {
    pendingNotificationRoute = null;
  }
}