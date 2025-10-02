import 'package:dawarich/core/database/drift/entities/user/user_table.dart';
import 'package:drift/drift.dart';

class UserSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Foreign key to the local UserTable
  IntColumn get userId => integer().references(UserTable, #id)();

  // Photo integrations
  TextColumn get immichUrl => text().nullable()();
  TextColumn get immichApiKey => text().nullable()();
  TextColumn get photoprismUrl => text().nullable()();
  TextColumn get photoprismApiKey => text().nullable()();

  // Map settings
  TextColumn get distanceUnit => text().nullable()(); // from maps.distanceUnit
  IntColumn get fogOfWarMeters => integer().nullable()();
  IntColumn get metersBetweenRoutes => integer().nullable()();
  TextColumn get preferredMapLayer => text().nullable()();
  BoolColumn get speedColoredRoutes => boolean().nullable()();
  TextColumn get pointsRenderingMode => text().nullable()();
  IntColumn get minutesBetweenRoutes => integer().nullable()();
  IntColumn get timeThresholdMinutes => integer().nullable()();
  IntColumn get mergeThresholdMinutes => integer().nullable()();
  BoolColumn get liveMapEnabled => boolean().nullable()();
  RealColumn get routeOpacity => real().nullable()();
  BoolColumn get visitsSuggestionsEnabled => boolean().nullable()();

  // Optional values returned as null in your sample
  TextColumn get speedColorScale => text().nullable()();
  IntColumn get fogOfWarThreshold => integer().nullable()();
}