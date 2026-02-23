
import 'package:dawarich/core/data/drift/entities/user/user_table.dart';
import 'package:drift/drift.dart';

class StatsCacheTable extends Table {

  IntColumn get userId => integer().references(UserTable, #id)();
  DateTimeColumn get syncedAt => dateTime()();
  TextColumn get payloadJson => text()();

  @override
  String get tableName => 'stats_cache';

  @override
  Set<Column> get primaryKey => {userId};
}