import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

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

  static const _dbFileName = 'dawarich_db.sqlite';
  static const _driftPortName = 'dawarich_drift_connect_port';

  static DriftIsolate? _memo;
  static Completer<DriftIsolate>? _creating;

  SQLiteClient(super.executor);

  static Future<SQLiteClient> connectSharedIsolate() async {
    if (_memo != null) {
      final conn = await _memo!.connect();
      return SQLiteClient(conn);
    }
    if (_creating != null) {
      final iso = await _creating!.future;
      final conn = await iso.connect();
      return SQLiteClient(conn);
    }

    final existing = IsolateNameServer.lookupPortByName(_driftPortName);
    if (existing != null) {
      final iso = DriftIsolate.fromConnectPort(existing);
      final conn = await iso.connect();
      _memo = iso;
      return SQLiteClient(conn);
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _dbFileName);

    for (var i = 0; i < 10; i++) {
      final again = IsolateNameServer.lookupPortByName(_driftPortName);
      if (again != null) {
        final iso = DriftIsolate.fromConnectPort(again);
        final conn = await iso.connect();
        _memo = iso;
        return SQLiteClient(conn);
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _creating = Completer<DriftIsolate>();
    try {
      final ready = ReceivePort();
      await Isolate.spawn(_dbIsolateEntry, [ready.sendPort, dbPath]);

      final iso = await ready.first
          .timeout(const Duration(seconds: 10)) as DriftIsolate;

      final ok = IsolateNameServer.registerPortWithName(iso.connectPort, _driftPortName);
      if (!ok) {
        final port = IsolateNameServer.lookupPortByName(_driftPortName)!;
        final existingIso = DriftIsolate.fromConnectPort(port);
        _creating!.complete(existingIso);
        _memo = existingIso;
        final conn = await existingIso.connect();
        return SQLiteClient(conn);
      }

      _creating!.complete(iso);
      _memo = iso;

      final conn = await iso.connect()
          .timeout(const Duration(seconds: 10));
      return SQLiteClient(conn);
    } catch (e, s) {
      _creating?.completeError(e, s);
      rethrow;
    } finally {
      _creating = null;
    }
  }

  static void _dbIsolateEntry(List<dynamic> args) {
    final send = args[0] as SendPort;
    final dbPath = args[1] as String;

    // Create a DriftIsolate hosted in this isolate
    final driftIso = DriftIsolate.inCurrent(() {
      final executor = NativeDatabase(
        File(dbPath),
        logStatements: kDebugMode,
      );
      return DatabaseConnection(executor);
    });

    send.send(driftIso);
  }

  /*
      You might wonder what this is doing here: db migrations do not run until the db is first interacted with.
      Here we run a dummy query to force the migration to run on start up rather than deep in the app.
      This is kinda hacky, but Drift does not provide a way to check if migrations are about to be run or not.
      So the only way to know if there is a migration to run, is to make it run the migration.
      The reason we do this in the first place, is because we want to show a migration screen, if we don't, the app gets stuck on the splash screen while it runs the migrations which is not a good user experience.

      When the migration runs, it will signal there is a migration, after signalling, it will block the migration until the UI is ready.
      When the UI is ready, it signals that to the migration logic which then unblocks the migration and proceeds with it.

      Flow (in a nutshell):
      1. Trigger migration with a dummy query.
      2. Migration logic runs and signals that there is a migration. Migration blocks it self with a Completer.
      3. Using the migration signal, we decide to show the migration screen (or not).
      4. When the migration screen is ready, it signals the migration logic to proceed, so it unblocks.
    */


  final _willUpgrade = Completer<bool>();      // true if onUpgrade will run, false otherwise
  Future<bool> get willUpgrade => _willUpgrade.future;


  final _migrationDone = Completer<bool>();
  Future<bool> get migrationDone => _migrationDone.future;
  final _uiReady = Completer<void>();

  Future<void>? _openFuture;

  Future<void> ensureOpened() => _openFuture ??= _openOnce();

  Future<void> _openOnce() async {
    final sw = Stopwatch()..start();
    try {
      await _completeWillUpgradeEarlyIfUnset();

      await _forceOpen().timeout(const Duration(seconds: 5));

      await Future<void>.delayed(Duration.zero);

      if (!_willUpgrade.isCompleted) {
        await _fallbackCompleteWillUpgradeIfUnset();
      }
    } on TimeoutException catch (e, s) {
      _completeErrorIfUnset(e, s);
      // optional: allow future retries
      // _openFuture = null;
      // Do not rethrow if ensureOpened() is commonly unawaited.
    } catch (e, s) {
      _completeErrorIfUnset(e, s);
      // optional: allow future retries
      // _openFuture = null;
    } finally {
      if (kDebugMode) {
        debugPrint('[DB] ensureOpened finished in ${sw.elapsedMilliseconds}ms');
      }
    }
  }

  Future<void> _completeWillUpgradeEarlyIfUnset() async {
    if (_willUpgrade.isCompleted) return;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _dbFileName);
    final f = File(dbPath);
    if (!await f.exists()) { _completeWillUpgrade(false); return; }

    RandomAccessFile? raf;
    try {
      raf = await f.open(mode: FileMode.read);
      final hdr = await raf.read(64);
      if (hdr.length < 64) return; // let hooks finish it
      final userVersion =
      (hdr[60] << 24) | (hdr[61] << 16) | (hdr[62] << 8) | hdr[63];
      _completeWillUpgrade(userVersion < schemaVersion);
    } finally { await raf?.close(); }
  }

  void _completeWillUpgrade(bool value) {
    if (!_willUpgrade.isCompleted) _willUpgrade.complete(value);
  }

  void _completeMigration(bool didMigrate) {
    if (!_migrationDone.isCompleted) _migrationDone.complete(didMigrate);
  }

  void _completeErrorIfUnset(Object e, StackTrace s) {
    if (!_willUpgrade.isCompleted) _willUpgrade.completeError(e, s);
    if (!_migrationDone.isCompleted) _migrationDone.completeError(e, s);
  }

  Future<void> _fallbackCompleteWillUpgradeIfUnset() async {

    if (_willUpgrade.isCompleted) {
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _dbFileName);
    final exists = await File(dbPath).exists();
    if (!exists) {
      _completeWillUpgrade(false);
      return;
    }

    final rows = await customSelect('PRAGMA user_version').get();
    final currentVersion = (rows.first.data.values.first as int);
    final needUpgrade = currentVersion < schemaVersion;

    _completeWillUpgrade(needUpgrade);
  }

  Future<void> _forceOpen() async {
    await customSelect('SELECT 1').get();
  }

  void signalUiReadyForMigration() {
    if (!_uiReady.isCompleted) {
      _uiReady.complete();
    }
  }

  @override
  int get schemaVersion => 4;

  // --- Migration helpers (added) -------------------------------------------

  // CTE update computing all deduplication keys (full rebuild)
  static const _dedupFullRebuildSql = r'''
    WITH computed AS (
      SELECT 
        p.id,
        p.user_id || '|' || pp.timestamp || '|' || pg.longitude || ',' || pg.latitude AS new_key
      FROM points_table p
      JOIN point_properties_table pp ON pp.id = p.properties_id
      JOIN point_geometry_table pg ON pg.id = p.geometry_id
    )
    UPDATE 
      points_table
    SET 
      deduplication_key = (SELECT new_key FROM computed WHERE computed.id = points_table.id)
  ''';

  // Partial fill only for rows missing a key (used in v2)
  static const _dedupFillMissingSql = r'''
    WITH computed AS (
      SELECT 
        p.id,
        p.user_id || '|' || pp.timestamp || '|' || pg.longitude || ',' || pg.latitude AS new_key
      FROM points_table p
      JOIN point_properties_table pp ON pp.id = p.properties_id
      JOIN point_geometry_table pg ON pg.id = p.geometry_id
      WHERE p.deduplication_key IS NULL OR p.deduplication_key = ''
    )
    UPDATE points_table
    SET deduplication_key = (SELECT new_key FROM computed WHERE computed.id = points_table.id)
    WHERE id IN (SELECT id FROM computed)
  ''';

  static const _dedupRemoveDuplicatesSql = r'''
    DELETE FROM points_table
    WHERE id NOT IN (
      SELECT MIN(id)
      FROM points_table
      GROUP BY deduplication_key
    )
  ''';

  static const _dedupCreateIndexSql = r'''
    CREATE UNIQUE INDEX IF NOT EXISTS unique_deduplication_key
    ON points_table(deduplication_key)
  ''';

  Future<void> _rebuildDedupKeys({required bool forceAll}) async {
    await customStatement(forceAll ? _dedupFullRebuildSql : _dedupFillMissingSql);
    await customStatement(_dedupRemoveDuplicatesSql);
    await customStatement(_dedupCreateIndexSql);
  }

  Future<void> _withPerfPragmas(Future<void> Function() body) async {
    await customStatement('PRAGMA synchronous = NORMAL;');
    await customStatement('PRAGMA temp_store = MEMORY;');
    await customStatement('PRAGMA cache_size = -40000;'); // ~40 MB
    try {
      await body();
    } finally {
      // Restore durability.
      await customStatement('PRAGMA synchronous = FULL;');
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(

    onCreate: (final m) async {
      debugPrint("[Drift] onCreate triggered");
      await m.createAll();
      _completeWillUpgrade(false);
      _completeMigration(false);
    },
    onUpgrade: (final m, final from, final to) async {

      if (kDebugMode) {
        debugPrint('[Migration] Running from version $from to $to');
      }

      _completeWillUpgrade(true);
      await _uiReady.future;

      await _withPerfPragmas(() async {
        await transaction(() async {

          if (from < 2 && to >= 2) {
            // Version 2: split coordinates + introduce deduplication_key
            await m.addColumn(pointGeometryTable, pointGeometryTable.longitude);
            await m.addColumn(pointGeometryTable, pointGeometryTable.latitude);
            await m.addColumn(pointsTable, pointsTable.deduplicationKey);

            await customStatement(r'''
              UPDATE point_geometry_table
              SET
                longitude = CAST(substr(coordinates, 1, instr(coordinates, ',') - 1) AS REAL),
                latitude  = CAST(substr(coordinates, instr(coordinates, ',') + 1) AS REAL)
            ''');

            await m.dropColumn(pointGeometryTable, 'coordinates');

            await _rebuildDedupKeys(forceAll: false);

            if (kDebugMode) {
              debugPrint('[Migration] Successfully ran version 2 migration');
            }
          }

            if (from < 3 && to >= 3) {
              await m.createTable(trackerSettingsTable);
              if (kDebugMode) {
                debugPrint('[Migration] Successfully ran version 3 migration');
              }
            }

          if (from < 4 && to >= 4) {
            if (kDebugMode) {
              debugPrint('[Migration] Running version 4 migration');
              debugPrint('[Migration] Converting text timestamps to unix timestamps');
            }

            await m.alterTable(
              TableMigration(
                pointPropertiesTable,
                columnTransformer: {
                  pointPropertiesTable.timestamp: const CustomExpression<int>(r"""
                    CASE
                      WHEN typeof(timestamp) = 'integer' THEN
                        CASE
                          WHEN length(CAST(timestamp AS TEXT)) >= 16 THEN CAST(timestamp / 1000000 AS INT)
                          WHEN length(CAST(timestamp AS TEXT)) BETWEEN 13 AND 14 THEN CAST(timestamp / 1000 AS INT)
                          WHEN length(CAST(timestamp AS TEXT)) BETWEEN 10 AND 11 THEN timestamp
                          ELSE NULL
                        END
                      WHEN typeof(timestamp) = 'text' THEN
                        strftime('%s',
                          CASE
                            WHEN instr(timestamp, '.') > 0
                              THEN replace(substr(timestamp, 1, instr(timestamp, '.') - 1), 'T', ' ')
                            ELSE replace(replace(timestamp, 'Z', ''), 'T', ' ')
                          END
                        )
                      ELSE NULL
                    END
                  """)
                },
              ),
            );

            // Rebuild all dedup keys (timestamp base changed)
            await customStatement('DROP INDEX IF EXISTS unique_deduplication_key;');
            await _rebuildDedupKeys(forceAll: true);

            if (kDebugMode) {
              debugPrint('[Migration] Successfully ran version 4 migration!');
            }
          }

          _completeMigration(true);
        });
      });
    },
    beforeOpen: (details) async {
      // This gets called after onUpgrade or onCreate
      await customStatement('PRAGMA journal_mode = WAL;');

      if (kDebugMode) {
        // Add operations here in case you need development specific db operations
        // Any code here will run before the database is opened
        debugPrint('[Drift] Currently on schema version: ${details.versionNow}');
      }

      if (!_willUpgrade.isCompleted) {
        _completeWillUpgrade(details.hadUpgrade);
      }

      if (!_migrationDone.isCompleted && (details.wasCreated || !details.hadUpgrade)) {
        _completeMigration(false);
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
