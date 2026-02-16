
import 'package:dawarich/core/constants/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class TrackerNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized;

  TrackerNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    bool initialized = false,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _initialized = initialized;

  Future<void> init({
    required void Function(NotificationResponse response) onTap,
  }) async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('ic_bg_service_small');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onTap,
    );

    _initialized = true;

    if (kDebugMode) {
      debugPrint('[TrackerNotificationService] initialized');
    }
  }

  Future<NotificationAppLaunchDetails?> getLaunchDetails() {
    return _plugin.getNotificationAppLaunchDetails();
  }

  Future<void> showTracker({
    required String title,
    required String body,
    String payload = '/tracker',
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
      icon: NotificationConstants.notificationIcon,
    );

    const details = NotificationDetails(android: android);

    await _plugin.show(
      NotificationConstants.notificationId,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> cancelTracker() {
    return _plugin.cancel(NotificationConstants.notificationId);
  }
}