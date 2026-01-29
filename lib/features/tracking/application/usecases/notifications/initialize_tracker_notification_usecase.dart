
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class InitializeTrackerNotificationService {

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Stores the pending route payload if app was launched from notification
  static String? pendingNotificationRoute;

  /// Initialize notification plugin and check for launch details.
  /// Should be called once during app boot.
  Future<void> call() async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings = AndroidInitializationSettings('ic_bg_service_small');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped
    );

    final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null) {
        if (kDebugMode) {
          debugPrint('[NotificationService] App launched from notification with payload: $payload');
        }
        pendingNotificationRoute = payload;
      }
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Notification tapped with payload: $payload');
      }
      final route = AppRouter.routeFromPath(payload);
      appRouter.push(route);
    }
  }

  /// Clear the pending route (call after navigation is handled)
  static void clearPendingRoute() {
    pendingNotificationRoute = null;
  }

}