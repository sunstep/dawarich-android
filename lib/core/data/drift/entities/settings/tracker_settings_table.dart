

import 'package:drift/drift.dart';

class TrackerSettingsTable extends Table {

  BoolColumn get automaticTracking => boolean().nullable()();
  IntColumn get trackingFrequency => integer().nullable()();
  IntColumn get locationAccuracy => integer().nullable()();
  IntColumn get minimumPointDistance => integer().nullable()();
  IntColumn get pointsPerBatch => integer().nullable()();
  TextColumn get deviceId => text().nullable()();

  IntColumn get userId => integer()();

  @override
  Set<Column> get primaryKey => {userId};
}