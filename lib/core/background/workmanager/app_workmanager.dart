import 'package:dawarich/core/background/workmanager/expired_batch_upload_worker.dart';
import 'package:dawarich/core/background/workmanager/tracker_watchdog_worker.dart';
import 'package:dawarich/features/batch/data/background/batch_upload_bootstrap.dart';
import 'package:dawarich/features/stats/data/background/stats_background_refresh_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

// Task name constants — single source of truth for all WorkManager tasks.
const String kStatsRefreshTask = 'stats_refresh_daily';
const String kBatchUploadTask = 'batch_upload_check';

bool _workmanagerInitialized = false;

/// The ONE and ONLY WorkManager callback dispatcher for the entire app.
///
/// WorkManager only supports a single registered dispatcher.
/// Registering multiple dispatchers via separate [Workmanager.initialize]
/// calls causes each subsequent call to overwrite the previous one, silently
/// breaking all tasks whose handler was overwritten.
///
/// All task types must be routed through this single function.
@pragma('vm:entry-point')
void appWorkmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) {
      debugPrint('[AppWorkmanager] Dispatching task: $task');
    }

    switch (task) {
      case kStatsRefreshTask:
        await StatsBackgroundRefreshBootstrap.runInBackground(
            forceRefresh: true);
      case kBatchUploadTask:
        await BatchUploadBootstrap.runInBackground();
      case TrackingWatchdogWorker.uniqueWorkName:
        await TrackingWatchdogWorker.execute();
      case ExpiredBatchUploadWorker.uniqueWorkName:
        await ExpiredBatchUploadWorker.execute();
      default:
        if (kDebugMode) {
          debugPrint('[AppWorkmanager] Unknown task: $task — ignoring.');
        }
    }

    return true;
  });
}

/// Initialises WorkManager exactly once per app process.
///
/// Safe to call multiple times — subsequent calls are no-ops.
/// All schedulers must call this instead of calling
/// [Workmanager.initialize] themselves.
Future<void> ensureWorkmanagerInitialized() async {
  if (_workmanagerInitialized) return;
  await Workmanager().initialize(appWorkmanagerCallbackDispatcher);
  _workmanagerInitialized = true;
  if (kDebugMode) {
    debugPrint('[AppWorkmanager] Initialized');
  }
}

