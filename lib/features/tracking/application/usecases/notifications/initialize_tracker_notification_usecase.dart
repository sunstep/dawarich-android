
import 'package:dawarich/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class InitializeTrackerNotificationService {

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> call() async {

    const androidSettings = AndroidInitializationSettings('ic_bg_service_small');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped
    );

  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap here
    final String? payload = response.payload;
    if (payload != null) {
      // Use the appRouter to navigate to the specified route
      appRouter.navigatePath(payload);
    }
  }

}