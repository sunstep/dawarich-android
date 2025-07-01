import 'package:drift/drift.dart';

class TrackTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId => text()();
  DateTimeColumn get startTimestamp => dateTime()();
  DateTimeColumn get endTimestamp => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get userId => integer()();
}
