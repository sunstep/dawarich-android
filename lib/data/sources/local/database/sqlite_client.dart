import 'package:dawarich/data/sources/local/database/tables/point/point_properties_table.dart';
import 'package:dawarich/data/sources/local/database/tables/point/point_geometry_table.dart';
import 'package:dawarich/data/sources/local/database/tables/point/points_table.dart';
import 'package:dawarich/data/sources/local/database/tables/track/track_table.dart';
import 'package:dawarich/data/sources/local/database/tables/user/user_settings_table.dart';
import 'package:dawarich/data/sources/local/database/tables/user/user_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'sqlite_client.g.dart';

@DriftDatabase(
  tables: [
    UserTable, UserSettingsTable,
    PointsTable, PointGeometryTable, PointPropertiesTable, TrackTable
  ]
)
final class SQLiteClient extends _$SQLiteClient {
  SQLiteClient() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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