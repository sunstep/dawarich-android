import 'dart:async';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/services/point_automation_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_preferences_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void backgroundTrackingEntry(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint("[Background] Entry point reached");

  service.on('stopService').listen((event) async {
    final requestId = event?['requestId'];

    try {
      await backgroundGetIt<PointAutomationService>().stopTracking();
      debugPrint("[Background] stopTracking() completed");
    } catch (e, s) {
      debugPrint("[Background] Error in stopTracking: $e\n$s");
    }

    service.invoke('stopped', {'requestId': requestId});
    service.stopSelf();
  });

  unawaited(_startBackgroundTracking(service));
}

Future<void> _startBackgroundTracking(ServiceInstance service) async {
  try {
    await DependencyInjection.injectBackgroundDependencies(service);
    debugPrint("[Background] Dependencies injected");

    service.invoke('ready');
  } catch (e, s) {
    debugPrint("[Background] Dependency injection failed: $e\n$s");
    service.invoke('stopped');
    service.stopSelf();
    return;
  }

  try {
    await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
    debugPrint("[Background] Geolocator warmed up");
  } catch (e) {
    debugPrint('[Background] Geolocator warm-up failed: $e');
  }

  try {
    final shouldTrack = await backgroundGetIt<TrackerPreferencesService>()
        .getAutomaticTrackingPreference();

    if (!shouldTrack) {
      debugPrint("[Background] Automatic tracking is disabled — skipping startTracking()");
      service.stopSelf();
      return;
    }

    await backgroundGetIt<PointAutomationService>().startTracking();
    debugPrint("[Background] startTracking() called");
  } catch (e, s) {
    debugPrint("[Background] Error during startTracking: $e\n$s");
  }
}

@pragma('vm:entry-point')
final class BackgroundTrackingService {

  static bool _isStopping = false;
  static bool _hasInitializedListeners = false;

  static Future<void> initializeListeners() async {
    if (_hasInitializedListeners) return;
    _hasInitializedListeners = true;

    FlutterBackgroundService().on('newPoint').listen((event) async {
      if (event is Map<String, dynamic>) {
        try {
          final point = LocalPoint.fromJson(event);

          final localPointService = getIt<LocalPointService>();
          final storeResult = await localPointService.storePoint(point);

          if (storeResult case Ok()) {
            debugPrint('[BackgroundTrackingService] Successfully stored background point');
          } else if (storeResult case Err(value: final err)) {
            debugPrint('[BackgroundTrackingService] Failed to store background point: $err');
          }
        } catch (e, s) {
          debugPrint('[BackgroundTrackingService] Error handling newPoint: $e\n$s');
        }
      }
    });
  }

  static Future<void> ensureNotificationChannelExists() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'dawarich_foreground',
      'Dawarich Background Tracking',
      description: 'Used for location tracking in background',
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
        isForegroundMode: true,
        foregroundServiceTypes: [AndroidForegroundType.location],
        autoStart: false,
        foregroundServiceNotificationId: 777,
        notificationChannelId: 'dawarich_foreground',
        initialNotificationTitle: 'Dawarich is running',
        initialNotificationContent: 'Tracking your location in background',
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

    if (!await Geolocator.isLocationServiceEnabled() &&
        await Permission.locationAlways.isDenied ||
        await Permission.locationAlways.isPermanentlyDenied) {
      debugPrint('[BackgroundService] Background location permission missing.');
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