import 'dart:async';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/constants/notification.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/services/point_automation_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_settings_service.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
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
      await DependencyInjection.disposeBackgroundDependencies();
      backgroundService.stopSelf();
      return;
    }

    session.setUserId(user.id);

    final settingsSvc = backgroundGetIt<TrackerSettingsService>();
    final shouldTrack = await settingsSvc.getAutomaticTrackingSetting();


    if (shouldTrack) {
      _startBackgroundTracking(backgroundService);
    } else {
      debugPrint("[Background] Auto tracking OFF — exiting cleanly.");
      await DependencyInjection.disposeBackgroundDependencies();
      backgroundService.stopSelf();
    }


  }

  // Entry point decided that tracking should start. The logic starts from here.
  static Future<void> _startBackgroundTracking(ServiceInstance backgroundService) async {

    if (kDebugMode) {
      debugPrint('[Background] Auto tracking ON - Starting background tracking...');
    }

    _registerListeners(backgroundService);

    if (kDebugMode) {
      debugPrint('[Background] Starting automatic tracking...');
    }

    final LocalPointService localPointService = backgroundGetIt<LocalPointService>();
    final Option<LastPoint> lastPointResult = await localPointService.getLastPoint();
    final batchPointCount = await localPointService.getBatchPointsCount();

    if (backgroundService is AndroidServiceInstance) {
      if (lastPointResult case Some(value: final lastPoint)) {
        await backgroundService.setForegroundNotificationInfo(
            title: "Dawarich Tracking",
            content: "Last updated at: ${lastPoint.timestamp.toLocal()}, $batchPointCount points in batch."
        );
      } else {
        backgroundService.setForegroundNotificationInfo(
            title: "Dawarich Tracking",
            content: "Tracking in the background, no points recorded yet."
        );
      }
    }

    await backgroundGetIt<PointAutomationService>().startTracking();
  }

  static Future<void> _registerListeners(ServiceInstance backgroundService) async {

    if (kDebugMode) {
      debugPrint('[Background] Registering listeners...');
    }

    backgroundService.on('stopService').listen((event) async {
      final requestId = event?['requestId'];

      try {
        if (backgroundGetIt.isRegistered<PointAutomationService>()) {
          await backgroundGetIt<PointAutomationService>().stopTracking();
          debugPrint("[Background] stopTracking() completed");
        } else {
          debugPrint("[Background] PointAutomationService not registered — skipping stopTracking");
        }

      } catch (e, s) {
        debugPrint("[Background] Error in stopTracking: $e\n$s");
      } finally {
        backgroundService.invoke('stopped', {'requestId': requestId});
        await DependencyInjection.disposeBackgroundDependencies();
        backgroundService.stopSelf();
      }
      
    });


  }

}

@pragma('vm:entry-point')
final class BackgroundTrackingService {

  static bool _isStopping = false;
  static bool _hasInitializedListeners = false;

  static Future<void> initializeListeners() async {
    if (_hasInitializedListeners) return;
    _hasInitializedListeners = true;

    final FlutterBackgroundService backgroundService = FlutterBackgroundService();

    backgroundService.on('newPoint').listen((event) async {

      if (event is Map<String, dynamic>) {
        final LocalPointService localPointService = getIt<LocalPointService>();
        try {
          final point = LocalPoint.fromJson(event);
          final String key = point.deduplicationKey;

          final storeResult = await localPointService.autoStoreAndUpload(point);

          backgroundService.invoke('pointStoredAck', {
            'deduplicationKey': key,
            'success': storeResult is Ok,
          });

          if (storeResult case Ok()) {
            debugPrint('[BackgroundTrackingService] Stored background point');
          } else if (storeResult case Err(value: final err)) {
            debugPrint('[BackgroundTrackingService] Store failed: $err');
          }
        } catch (e, s) {
          debugPrint('[BackgroundTrackingService] Error: $e\n$s');
        }
      }
    });
  }


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