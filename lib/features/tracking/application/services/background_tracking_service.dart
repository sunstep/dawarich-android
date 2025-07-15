import 'dart:async';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/services/point_automation_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_settings_service.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/settings/tracker_settings_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_settings_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:session_box/session_box.dart';

@pragma('vm:entry-point')
void backgroundTrackingEntry(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint("[Background] Entry point reached");

  service.on('stopService').listen((event) async {
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
    }

    service.invoke('stopped', {'requestId': requestId});
    service.stopSelf();
  });

  // This is implemented to invert the order of operations:
  // Usually, the background tracking service starts before the main isolate.
  // This causes the background tracking service to fail, causing it to clear the user session.
  // Which then causes the main isolate to also fail with the user session because the background tracking cleared it.
  // Here, we wait for the main isolate to signal that it is ready before starting the background tracking.
  // Thre are only two places where this is used:
  // 1. When the app is starting up (when the main isolate has done its initialization).
  // 2. When the user toggles on automatic tracking. Or else the the tracking will never start.
  bool hasProceeded = false;
  service.on('proceed').listen((_) {
    debugPrint("[Background] UI signaled readiness via invoke");
    unawaited(_startBackgroundTracking(service));
    hasProceeded = true;
  });

  Future.delayed(const Duration(seconds: 10), () {
    if (!hasProceeded) {
      debugPrint("[Background] No 'proceed' signal received after 10s - stopping.");
      service.stopSelf();
    }

  });
}

Future<void> _startBackgroundTracking(ServiceInstance service) async {
  try {

    await DependencyInjection.injectBackgroundDependencies(service);
    await backgroundGetIt.allReady();
    
    SessionBox<User> sessionBox = backgroundGetIt<SessionBox<User>>();
    final User? user = await sessionBox.refreshSession();

    if (user == null) {
      debugPrint('[Background] No user found in session, stopping background tracking...');
      service.stopSelf();
      return;
    }

    sessionBox.setUserId(user.id);

    debugPrint("[Background] Dependencies injected, and user session refreshed");

    service.on('syncSettings').listen((event) {
      if (event != null && event['userId'] != null) {
        try {
          final settings = TrackerSettingsDto.fromJson(Map<String, dynamic>.from(event));
          backgroundGetIt<ITrackerSettingsRepository>().setAll(settings);

          service.invoke('syncSettingsAck');

          debugPrint('[Background] Tracker settings synchronized.');
        } catch (e, s) {
          debugPrint('[Background] Failed to parse tracker settings: $e\n$s');
        }
      }
    });

    service.on('updateFrequency').listen((_) async {
      try {
        await backgroundGetIt<PointAutomationService>().updateTimers();
        debugPrint("[Background] updateTimers() triggered from main isolate");
      } catch (e, s) {
        debugPrint("[Background] Failed to update timers: $e\n$s");
      }
    });

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
    final shouldTrack = await backgroundGetIt<TrackerSettingsService>()
        .getAutomaticTrackingSetting();

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

  static final Completer<void> _readyCompleter = Completer<void>();

  static Future<void> waitUntilReady() => _readyCompleter.future;

  static void markAsReady() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  static Future<void> initializeListeners() async {
    if (_hasInitializedListeners) return;
    _hasInitializedListeners = true;

    FlutterBackgroundService().on('newPoint').listen((event) async {
      if (event is Map<String, dynamic>) {
        try {
          final point = LocalPoint.fromJson(event);

          final localPointService = getIt<LocalPointService>();
          final storeResult = await localPointService.autoStoreAndUpload(point);

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