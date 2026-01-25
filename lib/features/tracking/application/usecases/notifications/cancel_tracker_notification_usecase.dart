
import 'package:dawarich/core/constants/notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Hide the tracking notification (e.g., when stopping tracking).
final class CancelTrackerNotificationUseCase {

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> call() => _notificationsPlugin.cancel(NotificationConstants.notificationId);


}