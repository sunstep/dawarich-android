import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/features/stats/data/repositories/stats_repository.dart';
import 'package:dawarich/features/stats/data/sources/local/stats_local_data_source.dart';
import 'package:dawarich/features/stats/data/sources/remote/stats_remote_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class StatsBackgroundRefreshBootstrap {
  static Future<void> runInBackground({required bool forceRefresh}) async {
    final container = ProviderContainer();
    try {

      final cfg = await container.read(apiConfigManagerProvider.future);

      if (!cfg.isConfigured) {
        if (kDebugMode) {
          debugPrint('[StatsBgRefresh] Skipping: ApiConfig not configured');
        }
        return;
      }

      final db = await container.read(sqliteClientProvider.future);
      final dio = await container.read(dioClientProvider.future);

      final cacheDs = StatsCacheDataSource(db.statsCacheDao);
      final remoteDs = StatsRemoteDataSource(dio);

      final repo = StatsRepository(cache: cacheDs, remote: remoteDs);
      await repo.getStats(forceRefresh: forceRefresh);
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[StatsBackgroundRefreshBootstrap] failed: $e\n$s');
      }
    } finally {
      container.dispose();
    }
  }
}