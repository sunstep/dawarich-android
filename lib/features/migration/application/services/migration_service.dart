import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/database/migrations/migration_step.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/result.dart';

final class MigrationService {
  final List<MigrationStep> _steps;

  MigrationService(final SQLiteClient driftDb)
      : _steps = [];

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

  Future<void> run(int from, int to) async {
    final applicable = _steps
        .where((s) => s.fromVersion >= from && s.toVersion <= to)
        .toList()
      ..sort((a, b) => a.fromVersion.compareTo(b.fromVersion));

    for (final step in applicable) {
      final result = await step.migrate();
      if (result case Err(value: final err)) {
        throw Exception("Migration ${step.fromVersion}→${step.toVersion} failed: $err");
      }

      if (kDebugMode) {
        debugPrint("[MigrationService] Applied migration ${step.fromVersion}→${step.toVersion}");
      }
    }
  }

}
