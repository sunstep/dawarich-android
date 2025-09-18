import 'package:dawarich/core/constants/notification.dart';
import 'package:dawarich/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class TrackingNotificationService {

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  static const trackerPayload = '/tracker';

  Future<void> initialize() async {

    if (_initialized) {
      return;
    }
    const androidSettings = AndroidInitializationSettings('ic_bg_service_small');

    const InitializationSettings initializationSettings =
        InitializationSettings(
        android: androidSettings,
    );

    await _notificationsPlugin.initialize(
        initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped
    );
    _initialized = true;

  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap here
    final String? payload = response.payload;
    if (payload != null) {
      // Use the appRouter to navigate to the specified route
      appRouter.navigatePath(payload);
    }
  }


  Future<void> showOrUpdate({
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      category: AndroidNotificationCategory.service,
      autoCancel: false,
    );
    const details = NotificationDetails(android: android);

    await _notificationsPlugin.show(
      NotificationConstants.notificationId,
      title,
      body,
      details,
      payload: payload ?? trackerPayload, // default to tracker
    );
  }

  /// Hide the tracking notification (e.g., when stopping tracking).
  Future<void> cancel() => _notificationsPlugin.cancel(NotificationConstants.notificationId);

  Future<bool> wasLaunchedFromNotification() async {
    final d = await _notificationsPlugin.getNotificationAppLaunchDetails();
    return d?.didNotificationLaunchApp == true;
  }



}