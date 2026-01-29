
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class WasLaunchedFromNotificationUseCase {

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<bool> call() async {
    final d = await _notificationsPlugin.getNotificationAppLaunchDetails();
    return d?.didNotificationLaunchApp == true;
  }
}