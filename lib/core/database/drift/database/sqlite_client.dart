import 'dart:async';
import 'dart:io';

import 'package:dawarich/core/database/drift/entities/point/point_geometry_table.dart';
import 'package:dawarich/core/database/drift/entities/point/point_properties_table.dart';
import 'package:dawarich/core/database/drift/entities/point/points_table.dart';
import 'package:dawarich/core/database/drift/entities/settings/tracker_settings_table.dart';
import 'package:dawarich/core/database/drift/entities/track/track_table.dart';
import 'package:dawarich/core/database/drift/entities/user/user_settings_table.dart';
import 'package:dawarich/core/database/drift/entities/user/user_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'sqlite_client.g.dart';

@DriftDatabase(tables: [
  UserTable,
  UserSettingsTable,
  PointsTable,
  PointGeometryTable,
  PointPropertiesTable,
  TrackTable,
  TrackerSettingsTable
])
final class SQLiteClient extends _$SQLiteClient {

  static DriftIsolate? _sharedIsolate;
  static const _dbFileName = 'dawarich_db.sqlite';

  SQLiteClient(super.executor);

  static Future<DriftIsolate> getSharedDriftIsolate() async {
    return _sharedIsolate ??= await createDriftIsolate();

  }

  static Future<SQLiteClient> connectSharedIsolate() async {
    if (_sharedIsolate == null) {
      final dbFile = await getDatabaseFile();
      _sharedIsolate = await DriftIsolate.spawn(
            () => DatabaseConnection(NativeDatabase(dbFile, logStatements: kDebugMode)),
      );
    }

    final connection = await _sharedIsolate!.connect();
    return SQLiteClient(connection);
  }

  static Future<File> getDatabaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _dbFileName));
  }

  final _migrationCtl = StreamController<bool>.broadcast();
  /// Emits `true` if an actual onUpgrade ran, or `false` if we hit beforeOpen
  /// with no upgrade (so you always get exactly one event per open).
  Stream<bool> get migrationStream => _migrationCtl.stream;

  static final _uiReady = Completer<void>();

  void signalMigrationUiReady() {
    if (!_uiReady.isCompleted) {
      _uiReady.complete();
    }
  }


  @override
  int get schemaVersion => 4;

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

        if (from < 2 && to >= 2) {

          await m.addColumn(pointGeometryTable, pointGeometryTable.longitude);
          await m.addColumn(pointGeometryTable, pointGeometryTable.latitude);
          await m.addColumn(pointsTable, pointsTable.deduplicationKey);

          await customStatement(r'''
            UPDATE 
              point_geometry_table
            SET 
              longitude = CAST(
                substr(
                  coordinates, 1, instr(coordinates, ',') - 1
                ) AS REAL
              ),
              latitude  = CAST(
                substr(
                  coordinates, instr(coordinates, ',') + 1
                ) AS REAL
              )
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
            final key = '$userId|$timestamp|$longitude,$latitude';

            await (update(pointsTable)..where((tbl) => tbl.id.equals(id)))
                .write(PointsTableCompanion(deduplicationKey: Value(key)));
          }

          await customStatement(r'''
            DELETE FROM 
              points_table
            WHERE 
              id NOT IN (
                SELECT 
                  MIN(id)
                FROM 
                  points_table
                GROUP BY 
                  deduplication_key
              )
          ''');

          await customStatement('''
            CREATE UNIQUE INDEX IF NOT EXISTS 
              unique_deduplication_key
            ON 
              points_table(deduplication_key)
          ''');
          if (kDebugMode) {
            debugPrint('[Migration] Successfully ran version 2 migration');
          }
        } if (from < 3 && to >= 3) {
          await m.createTable(trackerSettingsTable);

          if (kDebugMode) {
            debugPrint('[Migration] Successfully ran version 3 migration');
          }
        } if (from  < 4 && to >= 4) {

          await transaction(() async {
            if (kDebugMode) {
              debugPrint('[Migration] Running version 4 migration');
              debugPrint('[Migration] Turning off foreign key enforcement...');
            }

            await customStatement('PRAGMA foreign_keys = OFF;');

            await m.alterTable(
                TableMigration(pointPropertiesTable,
                  columnTransformer: {
                      pointPropertiesTable.timestamp: const CustomExpression<int>(
                          r"""
                            CASE
                              WHEN typeof(timestamp) = 'integer' THEN
                                CASE
                                  WHEN length(CAST(timestamp AS TEXT)) >= 16
                                    THEN CAST(timestamp / 1000000 AS INT)        -- microseconds → seconds
                                  WHEN length(CAST(timestamp AS TEXT)) BETWEEN 13 AND 14
                                    THEN CAST(timestamp / 1000 AS INT)           -- milliseconds → seconds
                                  WHEN length(CAST(timestamp AS TEXT)) BETWEEN 10 AND 11
                                    THEN timestamp                                -- already seconds
                                  ELSE NULL
                                END
                              WHEN typeof(timestamp) = 'text' THEN
                                strftime('%s',
                                  CASE
                                    -- strip fractional seconds
                                    WHEN instr(timestamp, '.') > 0
                                      THEN replace(substr(timestamp, 1, instr(timestamp, '.') - 1), 'T', ' ')
                                    ELSE replace(replace(timestamp, 'Z', ''), 'T', ' ')
                                  END
                                )                                                -- ISO8601 → seconds
                              ELSE NULL
                            END
                          """
                      )
                  }
                )
            );

            if (kDebugMode) {
              debugPrint('[Migration] Successfully ran version 4 migration! Turning back on foreign key enforcement...');
            }
            await customStatement('PRAGMA foreign_keys = ON;');
          });

        }

      }));

    },
    beforeOpen: (details) async {
      // This gets called after onUpgrade or onCreate
      await customStatement('PRAGMA journal_mode = WAL;');

      if (kDebugMode) {
        // Add operations here in case you need development specific db operations
        // Any code here will run before the database is opened
        debugPrint('[Drift] Currently on schema version: ${details.versionNow}');
      }

      // The migration controller should emit false, or else the UI will be stuck.
      if (details.wasCreated || !details.hadUpgrade) {
        _migrationCtl.add(false);
      }
    },
  );


  static Future<DriftIsolate> createDriftIsolate() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbFile = File('${directory.path}/$_dbFileName');

    return DriftIsolate.spawn(
        () => DatabaseConnection(
          NativeDatabase(dbFile, logStatements: kDebugMode),
        ),
    );
  }
}
