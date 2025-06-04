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

  Future<int> getUserVersion() async {

    final QueryRow row = await customSelect('PRAGMA user_version;').getSingle();

    final int value = row.read<int>('user_version');

    return value;
  }

  /// Set the sqlite user_version to [newVersion]
  Future<void> setUserVersion(int newVersion) async {
    final sql = 'PRAGMA user_version = $newVersion;';
    await customStatement(sql);
  }

}