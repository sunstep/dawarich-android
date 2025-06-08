import 'package:dawarich/data/drift/entities/database/migrations_table.dart';
import 'package:dawarich/data/drift/entities/point/point_geometry_table.dart';
import 'package:dawarich/data/drift/entities/point/point_properties_table.dart';
import 'package:dawarich/data/drift/entities/point/points_table.dart';
import 'package:dawarich/data/drift/entities/track/track_table.dart';
import 'package:dawarich/data/drift/entities/user/user_settings_table.dart';
import 'package:dawarich/data/drift/entities/user/user_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'sqlite_client.g.dart';

@DriftDatabase(
  tables: [
    UserTable, UserSettingsTable,
    PointsTable, PointGeometryTable, PointPropertiesTable, TrackTable,
    MigrationsTable
  ]
)
final class SQLiteClient extends _$SQLiteClient {
  SQLiteClient() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from == 2 && to == 1) {
        // no schema changes, so just continue
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'dawarich_db',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationDocumentsDirectory,
      ),
    );
  }


}