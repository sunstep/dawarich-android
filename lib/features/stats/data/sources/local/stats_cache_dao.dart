import 'package:dawarich/core/data/drift/database/sqlite_client.dart';
import 'package:dawarich/core/data/drift/entities/stats/stats_cache_table.dart';
import 'package:drift/drift.dart';

part 'stats_cache_dao.g.dart';

@DriftAccessor(tables: [StatsCacheTable])
class StatsCacheDao extends DatabaseAccessor<SQLiteClient> with _$StatsCacheDaoMixin {
  StatsCacheDao(super.db);

  static const int _singletonId = 1;

  Future<StatsCacheTableData?> getCacheRow() async {
    final query =
    select(db.statsCacheTable)..where((t) => t.id.equals(_singletonId));

    return query.getSingleOrNull();
  }

  Future<void> upsertStats({
    required String payloadJson,
    required DateTime syncedAt,
  }) async {

    final row = StatsCacheTableCompanion.insert(
      id: const Value(_singletonId),
      payloadJson: payloadJson,
      syncedAt: syncedAt,
    );

    await into(db.statsCacheTable).insertOnConflictUpdate(row);
  }

  Future<void> clear() async {
    await (delete(db.statsCacheTable)..where((t) => t.id.equals(_singletonId))).go();
  }

}