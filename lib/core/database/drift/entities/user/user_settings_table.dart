import 'package:dawarich/core/database/drift/entities/user/user_table.dart';
import 'package:drift/drift.dart';

class UserSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get immichUrl => text()();
  TextColumn get immichApiKey => text()();
  TextColumn get photoprismUrl => text()();
  TextColumn get photoprismApiKey => text()();
  IntColumn get userId => integer().references(UserTable, #id)();
}
