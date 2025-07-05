import 'dart:async';

import 'package:dawarich/core/database/drift/entities/point/point_geometry_table.dart';
import 'package:dawarich/core/database/drift/entities/point/point_properties_table.dart';
import 'package:dawarich/core/database/drift/entities/point/points_table.dart';
import 'package:dawarich/core/database/drift/entities/track/track_table.dart';
import 'package:dawarich/core/database/drift/entities/user/user_settings_table.dart';
import 'package:dawarich/core/database/drift/entities/user/user_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

part 'sqlite_client.g.dart';

@DriftDatabase(tables: [
  UserTable,
  UserSettingsTable,
  PointsTable,
  PointGeometryTable,
  PointPropertiesTable,
  TrackTable
])
final class SQLiteClient extends _$SQLiteClient {
  SQLiteClient([QueryExecutor? executor]) : super(executor ?? _openConnection());

  final _migrationCtl = StreamController<bool>.broadcast();
  /// Emits `true` if an actual onUpgrade ran, or `false` if we hit beforeOpen
  /// with no upgrade (so you always get exactly one event per open).
  Stream<bool> get migrationStream => _migrationCtl.stream;

  static final _uiReady = Completer<void>();

  static void signalUiReady() {
    if (!_uiReady.isCompleted) _uiReady.complete();
  }


  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(

    onCreate: (m) async {
      debugPrint("[Drift] onCreate triggered");
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {

      if (kDebugMode) {
        debugPrint('[Migration] Running from version $from to $to');
      }

      _migrationCtl.add(true);
      await _uiReady.future;

      await transaction((() async {

        if (from == 1 && to == 2) {

          await m.addColumn(pointsTable, pointsTable.deduplicationKey);
          await m.addColumn(pointGeometryTable, pointGeometryTable.longitude);
          await m.addColumn(pointGeometryTable, pointGeometryTable.latitude);

          await customStatement(r'''
            UPDATE point_geometry_table
               SET longitude = CAST(substr(coordinates, 1, instr(coordinates, ',') - 1) AS REAL),
                   latitude  = CAST(substr(coordinates, instr(coordinates, ',') + 1) AS REAL)
          ''');

          await m.dropColumn(pointGeometryTable, 'coordinates');

          final allRows = await customSelect(
            '''
              SELECT 
                points_table.id, 
                point_properties_table.timestamp, 
                point_geometry_table.longitude,
                point_geometry_table.latitude, 
                points_table.user_id 
              FROM 
                points_table
              JOIN 
                point_properties_table 
              ON 
                points_table.properties_id = point_properties_table.id
              JOIN 
                point_geometry_table 
              ON 
                points_table.geometry_id = point_geometry_table.id
          ''',
            readsFrom: {pointsTable, pointPropertiesTable, pointGeometryTable},
          ).get();

          for (final row in allRows) {
            final id = row.read<int>('id');
            final timestamp = row.read<String>('timestamp');
            final longitude = row.read<double>('longitude');
            final latitude = row.read<double>('latitude');
            final userId = row.read<int>('user_id');
            final key = '$userId|$timestamp|$longitude|$latitude';

            await (update(pointsTable)..where((tbl) => tbl.id.equals(id)))
                .write(PointsTableCompanion(deduplicationKey: Value(key)));
          }

        }


      }));

    },
    beforeOpen: (details) async {
      // This gets called after onUpgrade or onCreate
      if (details.wasCreated || !details.hadUpgrade) {
        _migrationCtl.add(false);
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
