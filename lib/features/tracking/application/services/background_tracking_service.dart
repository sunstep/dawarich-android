import 'dart:async';
import 'package:dawarich/core/constants/notification.dart';
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/features/tracking/application/services/db_gate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'background_tracking_entrypoint.dart';
import 'package:dawarich/features/tracking/application/usecases/get_batch_point_count_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/get_last_point_usecase.dart';



class BackgroundTrackingEntry {
  static ProviderContainer? _container;

  static Future<ProviderContainer> _ensureContainer() async {
    final existing = _container;
    if (existing != null) return existing;

    final container = ProviderContainer();
    // Ensure core deps are ready in background isolate.
    await container.read(coreProvider.future);
    _container = container;
    return container;
  }

  static Future<void> checkBackgroundTracking(ServiceInstance backgroundService, DbGate gate) async {
    if (kDebugMode) {
      debugPrint('[Background] Injecting background thread dependencies...');
    }

    final needsUpgrade = await SQLiteClient.peekNeedsUpgrade();

    if (needsUpgrade) {
      if (kDebugMode) {
        debugPrint('[Background] Upgrade pending → waiting for db_gate_open (not touching Drift).');
      }
      await gate.waitUntilOpen();
      if (kDebugMode) {
        debugPrint('[Background] Gate opened → continuing startup.');
      }
    } else {
      gate.open();
    }

    final container = await _ensureContainer();

    // Ensure session is loaded and valid.
    final session = await container.read(sessionBoxProvider.future);
    final user = await session.refreshSession();
    if (user == null) {
      if (kDebugMode) debugPrint('[Background] No user in session — exiting.');
      await shutdown(backgroundService, 'No user session');
      return;
    }
    session.setUserId(user.id);

    // Respect user's automatic tracking preference.
    try {
      final getSettings = await container.read(getTrackerSettingsUseCaseProvider.future);
      final settings = await getSettings();
      if (!settings.automaticTracking) {
        if (kDebugMode) {
          debugPrint('[Background] Auto tracking OFF → shutting down.');
        }
        await shutdown(backgroundService, 'Auto tracking OFF');
        return;
      }
    } catch (e, s) {
      // If settings can't be loaded, fail safe (don’t track) instead of silently tracking.
      if (kDebugMode) {
        debugPrint('[Background] Failed to load tracker settings ($e) → shutting down.\n$s');
      }
      await shutdown(backgroundService, 'Settings load failed');
      return;
    }

    await _startBackgroundTracking(backgroundService, container);
  }

  static Future<void> _startBackgroundTracking(
    ServiceInstance backgroundService,
    ProviderContainer container,
  ) async {
    if (kDebugMode) {
      debugPrint('[Background] Starting background tracking...');
    }

    final automation = await container.read(pointAutomationServiceProvider.future);
    await automation.startTracking();

    try {
      final getLastPoint = await container.read(getLastPointUseCaseProvider.future);
      final getBatchCount = await container.read(getBatchPointCountUseCaseProvider.future);
      await setInitialForegroundNotification(getLastPoint, getBatchCount, backgroundService);
    } catch (_) {
      // ignore
    }
  }

  static void registerListeners(ServiceInstance backgroundService) {
    backgroundService.on('stopService').listen((event) async {
      final requestId = event?['requestId'];
      try {
        final container = _container;
        if (container != null) {
          final automation = await container.read(pointAutomationServiceProvider.future);
          await automation.stopTracking();
        }
      } catch (e, s) {
        debugPrint('[Background] Error stopping tracking: $e\n$s');
      } finally {
        backgroundService.invoke('stopped', {'requestId': requestId});
        await shutdown(backgroundService, 'stopService event');
      }
    });
  }

  static Future<void> shutdown(ServiceInstance svc, String reason) async {
    if (kDebugMode) {
      debugPrint('[Background] Shutting down: $reason');
    }
    try {
      _container?.dispose();
    } catch (_) {}
    _container = null;
    svc.stopSelf();
  }

  static Future<void> setInitialForegroundNotification(
    GetLastPointUseCase getLastPoint,
    GetBatchPointCountUseCase getBatchPointsCount,
    ServiceInstance backgroundService,
  ) async {
    final lastPointResult = await getLastPoint();
    final batchPointCount = await getBatchPointsCount();

    if (backgroundService is AndroidServiceInstance) {
      if (lastPointResult case Some(value: final lp)) {
        await backgroundService.setForegroundNotificationInfo(
          title: 'Dawarich Tracking',
          content: 'Last updated at: ${lp.timestamp.toLocal()}, $batchPointCount points in batch.',
        );
      } else {
        await backgroundService.setForegroundNotificationInfo(
          title: 'Dawarich Tracking',
          content: 'Tracking in the background, no points recorded yet.',
        );
      }
    }
  }

}

@pragma('vm:entry-point')
final class BackgroundTrackingService {

  static bool _configured = false;
  static Completer<void>? _starting;
  static bool _isStopping = false;

  static bool _bgReady = false;
  static bool _dbReady = false;

  static Future<void> markDbReady() async {
    _dbReady = true;
    await _tryOpenGate();
  }

  static Future<void> _tryOpenGate() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();

    if (isRunning) {
      _bgReady = true;
    }

    if (!_bgReady || !_dbReady) {
      return;
    }

    service.invoke('db_gate_open');
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

  static Future<void> installConfigurationOnce() async {

    if (_configured) {
      return;
    }

    await ensureNotificationChannelExists();

    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: backgroundTrackingEntry,
        autoStartOnBoot: true,
        isForegroundMode: true,
        foregroundServiceTypes: [AndroidForegroundType.location],
        autoStart: false,
        foregroundServiceNotificationId: NotificationConstants.notificationId,
        notificationChannelId: NotificationConstants.channelId,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: backgroundTrackingEntry,
        onBackground: (_) async => true,
      ),
    );

    _configured = true;
  }


  /// Start (if needed) and push runtime config to the service.
  /// - Skips when a DB upgrade is pending, unless `force: true`
  /// - Safe/idempotent across concurrent callers
  static Future<void> configureService({bool force = false}) async {
    // coalesce concurrent calls
    if (_starting != null) {
      return _starting!.future;
    }

    _starting = Completer<void>();

    try {
      if (!force && await SQLiteClient.peekNeedsUpgrade()) {
        if (kDebugMode) debugPrint('[Tracker] Upgrade pending → skipping start');
        _starting!.complete();
        return;
      }

      await installConfigurationOnce();

      final service = FlutterBackgroundService();

      if (!await service.isRunning()) {
        await service.startService();

        final ready = Completer<void>();
        final sub = service.on('ready').listen((_) {
          if (!ready.isCompleted) ready.complete();
        });
        await ready.future.timeout(const Duration(seconds: 5), onTimeout: () {});
        await sub.cancel();
      }

      _bgReady = true;

      await _tryOpenGate();

      _starting!.complete();
    } catch (e, s) {
      if (kDebugMode) debugPrint('[Tracker] configureService failed: $e\n$s');
      _starting!.completeError(e, s);
      rethrow;
    } finally {
      _starting = null;
    }
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

    await installConfigurationOnce();

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