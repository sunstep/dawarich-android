
import 'package:dawarich/core/constants/notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class ShowTrackerNotificationUseCase {

  static const trackerPayload = '/tracker';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

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
}