import 'package:dawarich/core/background/workmanager/app_workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

// Task name constants are now defined in app_workmanager.dart.
// Re-exported here for backwards compatibility.
export 'package:dawarich/core/background/workmanager/app_workmanager.dart'
    show kStatsRefreshTask, kBatchUploadTask;

/// Initializes WorkManager and registers the periodic stats refresh task.
///
/// Call this once during startup after the user session has been confirmed.
/// WorkManager de-duplicates by `uniqueName`, so calling this multiple times
/// (e.g. after re-login) is safe — it will replace the existing task.
Future<void> initializeAndRegisterStatsWorker() async {
  await ensureWorkmanagerInitialized();

  await Workmanager().registerPeriodicTask(
    kStatsRefreshTask,
    kStatsRefreshTask,
    frequency: const Duration(hours: 24),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  if (kDebugMode) {
    debugPrint('[WorkManager] Periodic stats refresh task registered (24h)');
  }
}

/// Registers the periodic batch upload task.
///
/// This task runs every 15 minutes (Android WorkManager minimum) and handles:
///  - Threshold-based uploads (batch is full)
///  - Expiration-based uploads (batch has been sitting too long)
///
/// Always registered when tracking is active. The task itself decides
/// whether there is work to do.
Future<void> registerBatchUploadWorker() async {
  await ensureWorkmanagerInitialized();

  await Workmanager().registerPeriodicTask(
    kBatchUploadTask,
    kBatchUploadTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  if (kDebugMode) {
    debugPrint('[WorkManager] Batch upload task registered (15min)');
  }
}
