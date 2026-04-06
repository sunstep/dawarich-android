import 'dart:convert';

import 'package:dawarich/features/stats/data/data_transfer_objects/stats/stats_dto.dart';
import 'package:dawarich/core/data/drift/daos/stats_cache_dao.dart';
import 'package:option_result/option_result.dart';

final class StatsCacheEntry {
  final StatsDTO stats;
  final DateTime syncedAt;

  const StatsCacheEntry({
    required this.stats,
    required this.syncedAt,
  });
}

abstract interface class IStatsCacheDataSource {
  Future<Option<StatsCacheEntry>> getCachedStats(int userId);
  Future<Option<DateTime>> getLastSyncedAt(int userId);
  Future<void> upsert(int userId, {
    required StatsDTO stats,
    required DateTime syncedAt,
  });
  Future<void> clear(int userId);
}

final class StatsCacheDataSource implements IStatsCacheDataSource {

  final StatsCacheDao _dao;
  StatsCacheDataSource(this._dao);

  @override
  Future<Option<StatsCacheEntry>> getCachedStats(int userId) async {
    final row = await _dao.getCacheRow(userId);
    if (row == null) {
      return const None();
    }

    final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    final dto = StatsDTO.fromJson(json);

    return Some(
      StatsCacheEntry(
        stats: dto,
        syncedAt: row.syncedAt,
      ),
    );
  }

  @override
  Future<Option<DateTime>> getLastSyncedAt(int userId) async {
    final row = await _dao.getCacheRow(userId);
    if (row == null) {
      return const None();
    }
    return Some(row.syncedAt);
  }

  @override
  Future<void> upsert(int userId, {
    required StatsDTO stats,
    required DateTime syncedAt,
  }) async {
    await _dao.upsertStats(
      userId,
      payloadJson: jsonEncode(stats.toJson()),
      syncedAt: syncedAt,
    );
  }

  @override
  Future<void> clear(int userId) => _dao.clear(userId);
}