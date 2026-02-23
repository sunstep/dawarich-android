import 'package:dawarich/core/data/drift/database/sqlite_client.steps.dart';
import 'package:drift/drift.dart';

Future<void> migrateToV7(Migrator m, Schema7 schema) async {

  await m.drop(schema.statsCache);
  await m.createTable(schema.statsCache);
}