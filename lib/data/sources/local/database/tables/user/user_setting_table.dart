import 'package:dawarich/data/sources/local/database/tables/user/user_table.dart';
import 'package:drift/drift.dart';

class UserSettingTable extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get immichUrl => text().nullable()();
  TextColumn get immichApiKey => text().nullable()();
  TextColumn get photoprismUrl => text().nullable()();
  TextColumn get photoprismApiKey => text().nullable()();
  IntColumn get userId => integer().references(UserTable, #id)();
}