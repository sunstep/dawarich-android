import 'package:dawarich/features/stats/data/background/stats_background_refresh_bootstrap.dart';
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