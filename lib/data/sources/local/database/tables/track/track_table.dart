
import 'package:drift/drift.dart';

class TrackTable extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId => text()();
  DateTimeColumn get startTimestamp => dateTime()();
  DateTimeColumn get endTimestamp => dateTime()();
  IntColumn get status => integer()();
  IntColumn get userId => integer()();
}