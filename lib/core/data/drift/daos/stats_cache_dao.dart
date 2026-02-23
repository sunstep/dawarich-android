import 'package:dawarich/core/data/drift/database/sqlite_client.dart';
import 'package:dawarich/core/data/drift/entities/stats/stats_cache_table.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'stats_cache_dao.g.dart';

@DriftAccessor(tables: [StatsCacheTable])
class StatsCacheDao extends DatabaseAccessor<SQLiteClient> with _$StatsCacheDaoMixin {
  StatsCacheDao(super.db);


  Future<StatsCacheTableData?> getCacheRow(int userId) async {

    final query =
    select(db.statsCacheTable)..where((t) => t.userId.equals(userId));

    return query.getSingleOrNull();
  }

  Future<void> upsertStats(int userId, {
    required String payloadJson,
    required DateTime syncedAt,
  }) async {

    final row = StatsCacheTableCompanion.insert(
      userId: Value(userId),
      payloadJson: payloadJson,
      syncedAt: syncedAt,
    );

    await into(db.statsCacheTable).insertOnConflictUpdate(row);
  }

  Future<void> clear(int userId) async {
    await (delete(db.statsCacheTable)..where((t) => t.userId.equals(userId))).go();
  }

}