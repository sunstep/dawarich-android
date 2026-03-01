import 'package:dawarich/features/stats/data/background/stats_background_refresh_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

const String kStatsRefreshTask = 'stats_refresh_daily';

@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kStatsRefreshTask) {
      await StatsBackgroundRefreshBootstrap.runInBackground(forceRefresh: true);
    }
    return true;
  });
}

/// Initializes WorkManager and registers the periodic stats refresh task.
///
/// Call this once during startup after the user session has been confirmed.
/// WorkManager de-duplicates by `uniqueName`, so calling this multiple times
/// (e.g. after re-login) is safe — it will replace the existing task.
Future<void> initializeAndRegisterStatsWorker() async {
  await Workmanager().initialize(
    workmanagerCallbackDispatcher,
  );

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

