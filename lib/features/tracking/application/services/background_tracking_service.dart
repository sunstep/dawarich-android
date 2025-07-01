import 'dart:async';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/features/tracking/application/services/point_automation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

@pragma('vm:entry-point')
void backgroundTrackingEntry(ServiceInstance service) async {
  debugPrint("[Background] Entry point reached");


  await DependencyInjection.injectBackgroundDependencies();

  service.on('stopService').listen((event) async {
    await getIt<PointAutomationService>().stopTracking();
    service.invoke('stopped');
    service.stopSelf();
  });

  service.invoke('ready');

  try {
    await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0
    ));
  } catch (e) {
    debugPrint('[Background] Geolocator warm-up failed: $e');
  }

  await getIt<PointAutomationService>().startTracking();
}

@pragma('vm:entry-point')
final class BackgroundTrackingService {

  static bool _isStopping = false;


  static Future<void> configureService() async {
    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: backgroundTrackingEntry,
        isForegroundMode: true,
        foregroundServiceTypes: [AndroidForegroundType.location],
        autoStart: true,
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

    final readyCompleter = Completer<void>();
    final stopCompleter = Completer<void>();

    service.on('ready').listen((_) {
      debugPrint('[BackgroundService] Background isolate is ready.');
      readyCompleter.complete();
    });

    service.on('stopped').listen((_) {
      debugPrint('[BackgroundService] Stop confirmed.');
      stopCompleter.complete();
    });

    await readyCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('[BackgroundService] Timeout: background isolate never signaled ready.');
      },
    );

    if (!readyCompleter.isCompleted) {
      _isStopping = false;
      return;
    }

    service.invoke("stopService");

    await stopCompleter.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugPrint('[BackgroundService] Stop confirmation timed out.');
      },
    );

    _isStopping = false;
  }

}