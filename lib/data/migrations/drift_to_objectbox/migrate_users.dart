import 'package:dawarich/data/drift/database/sqlite_client.dart';
import 'package:dawarich/data/objectbox/entities/user/user_entity.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class MigrateUsers {

  final SQLiteClient _dritDb;
  final Store _obxDb;
  MigrateUsers(this._dritDb, this._obxDb);

  Future<Result<(), String>> startMigration() async {

    final allDriftRows = await _dritDb.select(_dritDb.userTable).get();
    final int driftRowCount = allDriftRows.length;

    if (driftRowCount == 0) {
      return Err("[DriftToObjectbox] user migration was not necessary due to empty Drift table");
    }


    try {
      Box<UserEntity> userBox = _obxDb.box<UserEntity>();

      if (userBox.count() == driftRowCount) {
        return Err("[DriftToObjectbox] User migration was not necessary due to the obx database having the same data as the Drift database");
      }

      final List<UserEntity> migratedTable = allDriftRows.map((row) {
        return UserEntity(
            id: row.id,
            remoteId: row.dawarichId,
            dawarichHost: row.dawarichEndpoint,
            email: row.email,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
            theme: row.theme,
            admin: row.admin
        );
      }).toList();

      userBox.putMany(migratedTable);

      final int obxCount = userBox.count();
      if (obxCount != driftRowCount) {
        return Err(
          "User migration mismatch: Drift=$driftRowCount, ObjectBox=$obxCount",
        );
      }


    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[DriftToObjectBox] User migration failed: $st');
      }
    }


    return Ok(());
  }


}