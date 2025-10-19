import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dawarich/core/database/drift/database/crypto/db_key_provider.dart';
import 'package:dawarich/core/database/drift/database/crypto/sqlcipher_bootstrap.dart';
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
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as s;


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

  static String get _dbFileName {

    if (kReleaseMode) {
      return 'dawarich_db.sqlite';
    }

    return 'dawarich_db_dev.sqlite';
  }

  static const _driftPortName = 'dawarich_drift_connect_port';

  static DriftIsolate? _memo;
  static Completer<DriftIsolate>? _creating;

  SQLiteClient(super.executor);

  static String _escapeSqlLiteral(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll("'", "''");

  static Future<bool> _isPlaintextDb(String path) async {
    final f = File(path);
    if (!await f.exists()) {
      return false;
    }
    final raf = await f.open();
    try {
      final header = await raf.read(16);
      if (header.length < 16) {
        return false;
      }
      const sig = [
        0x53,
        0x51,
        0x4C,
        0x69,
        0x74,
        0x65,
        0x20,
        0x66,
        0x6F,
        0x72,
        0x6D,
        0x61,
        0x74,
        0x20,
        0x33,
        0x00
      ];
      for (var i = 0; i < 16; i++) {
        if (header[i] != sig[i]) {
          return false;
        }
      }
      return true;
    } finally {
      await raf.close();
    }
  }

  static Future<void> _migratePlaintextToEncrypted({
    required String dbPath,
    required String hexKey,
  }) async {

    if (kDebugMode) {
      debugPrint('[DB] Checking if migration from plaintext to encrypted is needed for $dbPath');
    }

    final existing  = File(dbPath);
    final encrypted = File('$dbPath.enc_tmp');

    if (!await existing.exists()) {
      return;
    }

    if (!await _isPlaintextDb(dbPath)) {
      if (kDebugMode) {
        debugPrint('[DB] No migration needed, database is already encrypted.');
      }
      return;
    }

    final plaintextDb = s.sqlite3.open(dbPath, mode: s.OpenMode.readWrite);
    try {
      final escaped = _escapeSqlLiteral(encrypted.path);

      plaintextDb.execute(
          "ATTACH DATABASE '$escaped' AS encrypted KEY \"x'$hexKey'\";"
      );

      plaintextDb.execute("SELECT sqlcipher_export('encrypted');");

      final userVersion = plaintextDb
          .select('PRAGMA user_version;')
          .first.values.first as int;
      plaintextDb.execute('PRAGMA encrypted.user_version = $userVersion;');
      plaintextDb.execute('DETACH DATABASE encrypted;');
    } finally {
      plaintextDb.dispose();
    }

    if (await encrypted.exists()) {

      final wal = File('$dbPath-wal');
      final shm = File('$dbPath-shm');

      if (await wal.exists()) {
        await wal.delete();
      }

      if (await shm.exists()) {
        await shm.delete();
      }

      await existing.delete();
      await encrypted.rename(dbPath);
    }
  }

  static Future<SQLiteClient> connectSharedIsolate() async {

    if (kDebugMode) {
      debugPrint('[Drift] Creating or connecting to a Drift isolate');
    }

    await SqlcipherBootstrap.ensure();
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

      if (kDebugMode) {
        debugPrint('[Drift] Found existing isolate, connecting to it.');
      }

      final iso = DriftIsolate.fromConnectPort(existing);
      final conn = await iso.connect();
      _memo = iso;
      return SQLiteClient(conn);
    }

    if (kDebugMode) {
      debugPrint('[Drift] No existing isolate found, creating a new one.');
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

      final String hexKey = await DbKeyProvider().getOrCreateHexKey();
      final RootIsolateToken? token = RootIsolateToken.instance;
      await Isolate.spawn(_dbIsolateEntry, [ready.sendPort, dbPath, hexKey, token]);

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

    () async {

      final send = args[0] as SendPort;
      final dbPath = args[1] as String;
      final hexKey = args[2] as String;
      final RootIsolateToken? token = args[3] as RootIsolateToken?;

      if (Platform.isAndroid && token != null) {
        BackgroundIsolateBinaryMessenger.ensureInitialized(token);
      }

      await SqlcipherBootstrap.ensure();
      await _migratePlaintextToEncrypted(dbPath: dbPath, hexKey: hexKey);

      final driftIso = DriftIsolate.inCurrent(() {
        final executor = NativeDatabase(
            File(dbPath),
            logStatements: kDebugMode,
            setup: (rawDb) {
              rawDb.execute('PRAGMA cipher_compatibility = 4;');
              rawDb.execute('PRAGMA key = "x\'$hexKey\'";');
              rawDb.select('PRAGMA cipher_version;');
              rawDb.config.doubleQuotedStringLiterals = false;
              rawDb.execute('PRAGMA foreign_keys = ON;');
              rawDb.execute('PRAGMA journal_mode = WAL;');
            }
        );
        return DatabaseConnection(executor);
      });

      send.send(driftIso);
    }();

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


  Completer<void>? _uiReady = Completer<void>();

  Future<void>? _openFuture;

  Future<void> ensureOpened() => _openFuture ??= _forceOpen();

  // If true, onUpgrade will SKIP the heavy logic (UI-flow only)
  static const bool _devFakeOnly =
      !kReleaseMode && bool.fromEnvironment('DEV_FAKE_ONLY', defaultValue: true);

  static Future<String> dbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _dbFileName);
  }

  static Future<void> setUserVersion(int v) async {
    await SqlcipherBootstrap.ensure();
    final path = await dbPath();
    final db = s.sqlite3.open(path);
    final hexKey = await DbKeyProvider().getOrCreateHexKey();
    try {
      db.execute('PRAGMA key = "x\'$hexKey\'";');
      db.execute('PRAGMA user_version = $v;');
      db.execute('PRAGMA wal_checkpoint(TRUNCATE);');
    } finally {
      db.dispose();
    }
  }

  static Future<bool> peekNeedsUpgrade() async {
    await SqlcipherBootstrap.ensure();
    final path = await dbPath();
    if (!await File(path).exists()) {
      return false;
    }

    final hexKey = await DbKeyProvider().getOrCreateHexKey();

    try {
      final db = s.sqlite3.open(path, mode: s.OpenMode.readOnly);
      try {
        db.execute('PRAGMA key = "x\'$hexKey\'";');
        final uv = db.select('PRAGMA user_version;').first.values.first as int;
        return uv < kSchemaVersion;
      } finally {
        db.dispose();
      }
    } on s.SqliteException catch (e) {
      if (e.extendedResultCode == 26 || e.message.contains('file is not a database')) {
        if (kDebugMode) debugPrint('[DB] plaintext/corrupt db detected → not blocking startup');
        return false;
      }
      // other errors → be conservative
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<void> _forceOpen() async {
    await customSelect('SELECT 1').get();
  }

  void signalUiReadyForMigration() {

    final c = _uiReady ??= Completer<void>();
    if (!c.isCompleted){
      c.complete();
    }
  }

  Future<void> _waitForUi() => (_uiReady ??= Completer<void>()).future;

  void resetForRetry() {
    _openFuture = null;     // allow ensureOpened() to run again
    _uiReady = null;       // re-block until UI signals again
  }

  static const int kSchemaVersion = 4;
  @override
  int get schemaVersion => kSchemaVersion;

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
    },
    onUpgrade: (final m, final from, final to) async {

      if (kDebugMode) {
        debugPrint('[Migration] Running from version $from to $to');
      }

      await _waitForUi();

      if (_devFakeOnly) {

        if (kDebugMode) {
          debugPrint('[Migration][DEV] Fake-only mode: skipping SQL.');
        }

        await setUserVersion(kSchemaVersion);
        await customStatement('PRAGMA wal_checkpoint(FULL);');

        if (kDebugMode) {
          final version = await customSelect('PRAGMA user_version').getSingle();
          debugPrint('[Migration] Set user_version to $kSchemaVersion, '
              'current value: ${version.data['user_version']}');
        }


        await Future.delayed(const Duration(seconds: 5));
        return;
      }

      try {
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
          });

          await setUserVersion(kSchemaVersion);
          await customStatement('PRAGMA wal_checkpoint(FULL);');
          await customStatement('PRAGMA optimize;');
        });
      } catch (e, s) {
        if (kDebugMode) {
          debugPrint('[Migration] Migration failed: $e\n$s');
        }

        rethrow;
      }


    },
    beforeOpen: (details) async {
      // This gets called after onUpgrade or onCreate
      await customStatement('PRAGMA journal_mode = WAL;');

      if (kDebugMode) {
        // Add operations here in case you need development specific db operations
        // Any code here will run before the database is opened
        debugPrint('[Drift] Currently on schema version: ${details.versionNow}');
      }

      if (details.hadUpgrade || details.wasCreated) {
        await customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
      }

    },
  );

}
