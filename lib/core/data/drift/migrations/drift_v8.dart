import 'package:dawarich/core/data/drift/database/sqlite_client.steps.dart';
import 'package:drift/drift.dart';

Future<void> migrateToV8(Migrator m, Schema8 schema) async {
  // Drop in case a previous dev build created the table without all columns.
  await m.drop(schema.appSettingsTable);
  await m.createTable(schema.appSettingsTable);
}


