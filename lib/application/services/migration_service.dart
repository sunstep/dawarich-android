import 'package:dawarich/application/interfaces/migration_step.dart';
import 'package:dawarich/application/migrations/drift_to_obx_migration.dart';
import 'package:dawarich/data/drift/database/sqlite_client.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:flutter/foundation.dart';

final class MigrationService {
  final List<MigrationStep> _steps;

  final SQLiteClient _driftDatabase;
  MigrationService(this._driftDatabase, final Store _obxDb)
      : _steps = [DriftToObxMigration(_driftDatabase, _obxDb)];

  Future<bool> needsMigration() async {
    for (final step in _steps) {
      bool pending = false;
      try {
        pending = await step.isPending;
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              '[MigrationService] failed to check step ${step.fromVersion}→${step.toVersion}: $e');
        }
      }

      if (pending) {
        return true;
      }
    }

    return false;
  }

  Future<void> runIfNeeded() async {
    final List<bool> pendingFlags = await Future.wait(
      _steps.map((step) => step.isPending),
    );

    final migrationsByVersion = <int, MigrationStep>{};
    final pendingVersions = <int>{};
    for (var i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      migrationsByVersion[step.fromVersion] = step;
      if (pendingFlags[i]) pendingVersions.add(step.fromVersion);
    }

    if (pendingVersions.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            '[MigrationService] No migrations pending; database is up-to-date.');
      }
      return;
    }

    final int firstVersion = pendingVersions.reduce((x, y) => x < y ? x : y);
    if (kDebugMode) {
      debugPrint(
          '[MigrationService] Starting migrations at version $firstVersion');
    }

    int currentVersion = firstVersion;
    MigrationStep? step = migrationsByVersion[currentVersion];

    while (step != null) {
      if (kDebugMode) {
        debugPrint(
          '[MigrationService] Applying migration '
          '${step.fromVersion} → ${step.toVersion}',
        );
      }

      try {
        await step.migrate();
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('[Drift->ObjectBox] Failed to migrate: $st');
        }
      }

      if (kDebugMode) {
        debugPrint(
            '[MigrationService] Successfully applied migration ${step.fromVersion} → ${step.toVersion}');
      }

      currentVersion = step.toVersion;
      step = migrationsByVersion[currentVersion];
    }

    if (kDebugMode) {
      debugPrint(
          '[MigrationService] All done, final version = $currentVersion');
    }
  }
}
