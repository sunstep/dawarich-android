import 'package:dawarich/features/batch/data/background/batch_upload_bootstrap.dart';
import 'package:dawarich/features/stats/data/background/stats_background_refresh_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

const String kStatsRefreshTask = 'stats_refresh_daily';
const String kBatchUploadTask = 'batch_upload_check';

bool _workmanagerInitialized = false;

@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kStatsRefreshTask) {
      await StatsBackgroundRefreshBootstrap.runInBackground(forceRefresh: true);
    } else if (task == kBatchUploadTask) {
      await BatchUploadBootstrap.runInBackground();
    }
    return true;
  });
}

/// Ensures WorkManager is initialized exactly once.
/// Safe to call multiple times — subsequent calls are no-ops.
Future<void> _ensureInitialized() async {
  if (_workmanagerInitialized) return;
  await Workmanager().initialize(workmanagerCallbackDispatcher);
  _workmanagerInitialized = true;
  if (kDebugMode) {
    debugPrint('[WorkManager] Initialized');
  }
}

/// Initializes WorkManager and registers the periodic stats refresh task.
///
/// Call this once during startup after the user session has been confirmed.
/// WorkManager de-duplicates by `uniqueName`, so calling this multiple times
/// (e.g. after re-login) is safe — it will replace the existing task.
Future<void> initializeAndRegisterStatsWorker() async {
  await _ensureInitialized();

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
  await _ensureInitialized();

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

