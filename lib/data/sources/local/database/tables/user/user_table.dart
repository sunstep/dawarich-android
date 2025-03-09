import 'package:drift/drift.dart';

class UserTable extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get theme => text()();
}