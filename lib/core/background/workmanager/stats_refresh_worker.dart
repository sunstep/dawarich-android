import 'package:dawarich/features/batch/data/background/batch_expiration_bootstrap.dart';
import 'package:dawarich/features/stats/data/background/stats_background_refresh_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

const String kStatsRefreshTask = 'stats_refresh_daily';
const String kBatchExpirationTask = 'batch_expiration_check';

bool _workmanagerInitialized = false;

@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kStatsRefreshTask) {
      await StatsBackgroundRefreshBootstrap.runInBackground(forceRefresh: true);
    } else if (task == kBatchExpirationTask) {
      await BatchExpirationBootstrap.runInBackground();
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

/// Registers (or replaces) the batch expiration periodic task.
///
/// The task runs every 15 minutes (Android WorkManager minimum) and checks
/// whether the oldest un-uploaded point exceeds the user's configured
/// expiration threshold.  If so, it uploads the batch.
///
/// Pass `enabled: false` to cancel the task when the user disables expiration.
Future<void> registerBatchExpirationWorker({bool enabled = true}) async {
  await _ensureInitialized();

  if (!enabled) {
    await Workmanager().cancelByUniqueName(kBatchExpirationTask);
    if (kDebugMode) {
      debugPrint('[WorkManager] Batch expiration task cancelled');
    }
    return;
  }

  await Workmanager().registerPeriodicTask(
    kBatchExpirationTask,
    kBatchExpirationTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
  );

  if (kDebugMode) {
    debugPrint('[WorkManager] Batch expiration task registered (15min)');
  }
}

