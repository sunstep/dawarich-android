import 'package:dawarich/core/data/drift/database/sqlite_client.steps.dart';
import 'package:drift/drift.dart';

Future<void> migrateToV9(Migrator m, Schema9 schema) async {
  await m.addColumn(
    schema.trackerSettingsTable,
    schema.trackerSettingsTable.batchExpirationMinutes,
  );
}

