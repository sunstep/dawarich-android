
import 'package:drift/drift.dart';

class StatsCacheTable extends Table {

  IntColumn get id => integer().withDefault(const Constant(1))();
  DateTimeColumn get syncedAt => dateTime()();
  TextColumn get payloadJson => text()();

  @override
  String get tableName => 'stats_cache';

  @override
  Set<Column> get primaryKey => {id};
}