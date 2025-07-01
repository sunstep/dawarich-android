import 'package:drift/drift.dart';

class UserTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dawarichId => integer().nullable()();
  TextColumn get dawarichEndpoint => text().nullable()();
  TextColumn get email => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get theme => text()();
  BoolColumn get admin => boolean()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {dawarichId, dawarichEndpoint}
      ];
}
