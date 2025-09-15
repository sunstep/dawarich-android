import 'dart:async';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/constants/notification.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/services/point_automation_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_settings_service.dart';
import 'package:dawarich/features/tracking/application/services/tracking_notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:session_box/session_box.dart';

@pragma('vm:entry-point')
void backgroundTrackingEntry(ServiceInstance backgroundService) {

  if (kDebugMode) {
    debugPrint('[Background] Entry point reached');
  }

  WidgetsFlutterBinding.ensureInitialized();
  unawaited(BackgroundTrackingEntry.checkBackgroundTracking(backgroundService));
}

class BackgroundTrackingEntry {

  static Future<void> checkBackgroundTracking(ServiceInstance backgroundService) async {

    if (kDebugMode) {
      debugPrint('[Background] Injecting background thread dependencies...');
    }

    await DependencyInjection.injectBackgroundDependencies(backgroundService);
    await backgroundGetIt.allReady();

    final session = backgroundGetIt<SessionBox<User>>();
    final user = await session.refreshSession();

    if (user == null) {
      debugPrint("[Background] No user in session — exiting.");
      await _shutdown(backgroundService, "No user session");
      return;
    }

    session.setUserId(user.id);

    final settingsSvc = backgroundGetIt<TrackerSettingsService>();
    final shouldTrack = await settingsSvc.getAutomaticTrackingSetting();


    if (shouldTrack) {
      await _startBackgroundTracking(backgroundService);
      return;
    }
    await _shutdown(backgroundService, "Auto tracking OFF");


  }

  static Future<void> _startBackgroundTracking(ServiceInstance backgroundService) async {

    if (kDebugMode) {
      debugPrint('[Background] Auto tracking ON - Starting background tracking...');
    }

    _registerListeners(backgroundService);

    // Ensure notification plugin initialized in background isolate.
    await backgroundGetIt<TrackingNotificationService>().initialize();

    final localPointService = backgroundGetIt<LocalPointService>();
    await _setInitialForegroundNotification(localPointService, backgroundService);

    await backgroundGetIt<PointAutomationService>().startTracking();
  }

  static Future<void> _setInitialForegroundNotification(
    LocalPointService svc,
    ServiceInstance backgroundService,
  ) async {
    final lastPointResult = await svc.getLastPoint();
    final batchPointCount = await svc.getBatchPointsCount();

    if (backgroundService is AndroidServiceInstance) {
      if (lastPointResult case Some(value: final lp)) {
        await backgroundService.setForegroundNotificationInfo(
          title: "Dawarich Tracking",
          content: "Last updated at: ${lp.timestamp.toLocal()}, $batchPointCount points in batch.",
        );
      } else {
        await backgroundService.setForegroundNotificationInfo(
          title: "Dawarich Tracking",
          content: "Tracking in the background, no points recorded yet.",
        );
      }
    }
  }

  static void _registerListeners(ServiceInstance backgroundService) {
    // Simplified single listener with safe stop.
    backgroundService.on('stopService').listen((event) async {
      final requestId = event?['requestId'];
      try {
        if (backgroundGetIt.isRegistered<PointAutomationService>()) {
          await backgroundGetIt<PointAutomationService>().stopTracking();
        }
      } catch (e, s) {
        debugPrint("[Background] Error stopping tracking: $e\n$s");
      } finally {
        backgroundService.invoke('stopped', {'requestId': requestId});
        await _shutdown(backgroundService, "stopService event");
      }
    });
  }

  static Future<void> _shutdown(ServiceInstance svc, String reason) async {
    if (kDebugMode) {
      debugPrint('[Background] Shutting down: $reason');
    }
    await DependencyInjection.disposeBackgroundDependencies();
    svc.stopSelf();
  }

}

@pragma('vm:entry-point')
final class BackgroundTrackingService {

  static bool _isStopping = false;

  static Future<void> ensureNotificationChannelExists() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      description: NotificationConstants.channelDescription,
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

    await plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }


  static Future<void> configureService() async {

    await ensureNotificationChannelExists();

    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: backgroundTrackingEntry,
        autoStartOnBoot: true,
        isForegroundMode: true,
        foregroundServiceTypes: [AndroidForegroundType.location],
        autoStart: false,
        foregroundServiceNotificationId: NotificationConstants.notificationId,
        notificationChannelId: NotificationConstants.channelId
      ),

      iosConfiguration: IosConfiguration(
        onForeground: backgroundTrackingEntry,
        onBackground: (_) async => true,
      ),
    );


  }

  static Future<Result<(), String>> start() async {

    if (!(await Permission.notification.isGranted)) {
      debugPrint('[BackgroundService] Notification permission missing.');
      return Err("Notification permission is required.");
    }

    final locEnabled = await Geolocator.isLocationServiceEnabled();
    final always = await Permission.locationAlways.status;
    final hasBgPermission = always.isGranted;

    if (!locEnabled || !hasBgPermission) {
      return Err("Background location permission is required.");
    }

    final isRunning = await FlutterBackgroundService().isRunning();
    if (isRunning) {
      debugPrint('[BackgroundService] Already running — skipping start.');
      return Ok(());
    }

    final started = await FlutterBackgroundService().startService();
    return started
        ? Ok(())
        : Err("Failed to start background service.");
  }

  static Future<void> stop() async {
    final service = FlutterBackgroundService();

    final isRunning = await service.isRunning();
    if (!isRunning) {
      debugPrint('[BackgroundService] Stop skipped: service not running');
      return;
    }

    if (_isStopping) return;
    _isStopping = true;

    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final stopCompleter = Completer<void>();

    final sub = service.on('stopped').listen((event) {
      final eventId = event?['requestId'];
      if (eventId == requestId) {
        debugPrint('[BackgroundService] Stop confirmed for requestId $requestId.');
        stopCompleter.complete();
      } else {
        debugPrint('[BackgroundService] Received unrelated stop event with requestId $eventId.');
      }
    });

    debugPrint('[BackgroundService] Sending stopService request with ID $requestId...');
    service.invoke('stopService', {'requestId': requestId});

    try {
      await stopCompleter.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('[BackgroundService] Stop confirmation timed out for requestId $requestId.');
        },
      );
    } catch (_) {
      debugPrint('[BackgroundService] Stop confirmation failed or timed out.');
    } finally {
      await sub.cancel();
      _isStopping = false;
    }
  }

}