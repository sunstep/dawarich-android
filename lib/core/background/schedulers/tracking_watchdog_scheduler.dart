import 'package:dawarich/core/background/workmanager/tracker_watchdog_worker.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

final class TrackingWatchdogWorkScheduler {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await Workmanager().initialize(
      TrackingWatchdogWorker.callbackDispatcher,
    );

    _initialized = true;
  }

  static Future<void> register() async {
    await initialize();

    if (kDebugMode) {
      debugPrint('[TrackingWatchdog] Registering periodic watchdog.');
    }

    await Workmanager().registerPeriodicTask(
      TrackingWatchdogWorker.uniqueWorkName,
      TrackingWatchdogWorker.uniqueWorkName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  static Future<void> cancel() async {
    await initialize();

    if (kDebugMode) {
      debugPrint('[TrackingWatchdog] Cancelling periodic watchdog.');
    }

    await Workmanager().cancelByUniqueName(
      TrackingWatchdogWorker.uniqueWorkName,
    );
  }
}