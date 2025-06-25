import 'dart:io';

import 'package:dawarich/core/startup/migrations/interfaces/migration_step.dart';
import 'package:dawarich/core/data/drift/database/sqlite_client.dart';
import 'package:dawarich/data/migrations/drift_to_objectbox/drift_helper.dart';
import 'package:dawarich/data/migrations/drift_to_objectbox/migrate_point_geometry.dart';
import 'package:dawarich/data/migrations/drift_to_objectbox/migrate_point_properties.dart';
import 'package:dawarich/data/migrations/drift_to_objectbox/migrate_points.dart';
import 'package:dawarich/data/migrations/drift_to_objectbox/migrate_tracks.dart';
import 'package:dawarich/data/migrations/drift_to_objectbox/migrate_users.dart';
import 'package:dawarich/data/objectbox/entities/database/migrations_entity.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/result.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final class DriftToObxMigration implements MigrationStep {
  final SQLiteClient _driftDatabase;
  final Store _obxDb;
  DriftToObxMigration(this._driftDatabase, this._obxDb);

  @override
  int get fromVersion => 1;
  @override
  int get toVersion => 2;

  @override
  Future<bool> get isPending async {
    final docsDir = await getApplicationDocumentsDirectory();
    final driftFile = File(p.join(docsDir.path, 'dawarich_db.sqlite'));

    if (!await driftFile.exists()) {
      return false;
    }

    final migrationsBox = Box<MigrationsEntity>(_obxDb);
    final query = migrationsBox
        .query(MigrationsEntity_.fromVersion
            .equals(fromVersion)
            .and(MigrationsEntity_.toVersion.equals(toVersion))
            .and(MigrationsEntity_.success.equals(true)))
        .build();

    final count = query.count();
    query.close();

    if (count > 0) {
      return false;
    }

    final helper = DriftHelper(_driftDatabase);
    final bool hasRows = await helper.hasAnyRows();
    return hasRows;
  }

  @override
  Future<Result<(), String>> migrate() async {
    if (kDebugMode) {
      debugPrint('[Migration v1→v2] Starting Drift→ObjectBox');
    }

    Box<MigrationsEntity> migrationsBox = Box<MigrationsEntity>(_obxDb);
    final MigrationsEntity newMigration = MigrationsEntity(
        id: 0, fromVersion: fromVersion, toVersion: toVersion, success: false);

    final int migrationId = await migrationsBox.putAsync(newMigration);

    final steps = <Future<Result<(), String>> Function()>[
      () => MigrateUsers(_driftDatabase, _obxDb).startMigration(),
      () => MigrateTracks(_driftDatabase, _obxDb).startMigration(),
      () => MigratePointGeometry(_driftDatabase, _obxDb).startMigration(),
      () => MigratePointProperties(_driftDatabase, _obxDb).startMigration(),
      () => MigratePoints(_driftDatabase, _obxDb).startMigration(),
    ];

    int i = 0;
    while (i < steps.length) {
      final result = await steps[i]();

      if (result.isErr()) {
        final msg = result.unwrapErr();

        if (_isFatal(msg)) {
          if (kDebugMode) {
            debugPrint('[Migration v1→v2] step #${i + 1} FATAL: $msg');
          }
          return Err('v1→v2 step #${i + 1} failed: $msg');
        }

        if (kDebugMode) {
          debugPrint('[Migration v1→v2] step #${i + 1} skipped: $msg');
        }
      } else if (kDebugMode) {
        debugPrint('[Migration v1→v2] step #${i + 1} completed');
      }

      i++;
    }

    newMigration.id = migrationId;
    newMigration.success = true;
    await migrationsBox.putAsync(newMigration);

    return const Ok(());
  }

  bool Function(String msg) get _isFatal =>
      (String msg) => msg.contains('migration mismatch');
}
