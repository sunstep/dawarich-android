
import 'package:dawarich/core/data/drift/database/sqlite_client.steps.dart';
import 'package:drift/drift.dart';

Future<void> migrateToV6(Migrator m, Schema6 schema) async {
  await m.createTable(schema.statsCache);
}