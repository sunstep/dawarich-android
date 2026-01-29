import 'dart:io';

import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as s;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('migration_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('upgrade from v4 to v5 works', () async {
    final dbPath = p.join(tempDir.path, 'test_v4.db');

    // Create v4 database using sqlite3 package directly
    final v4Db = s.sqlite3.open(dbPath);

    // Create tables as they were in v4
    v4Db.execute('''
      CREATE TABLE user_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        dawarich_endpoint TEXT NOT NULL,
        dawarich_api_key TEXT NOT NULL,
        UNIQUE(email, dawarich_endpoint)
      );
    ''');

    v4Db.execute('''
      CREATE TABLE point_geometry_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        longitude REAL NOT NULL,
        latitude REAL NOT NULL
      );
    ''');

    v4Db.execute('''
      CREATE TABLE point_properties_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        battery_state TEXT NOT NULL,
        battery_level REAL NOT NULL,
        wifi TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        altitude REAL NOT NULL,
        speed REAL NOT NULL,
        horizontal_accuracy REAL NOT NULL,
        vertical_accuracy REAL NOT NULL,
        speed_accuracy REAL NOT NULL,
        course REAL NOT NULL,
        course_accuracy REAL NOT NULL,
        track_id TEXT,
        device_id TEXT NOT NULL
      );
    ''');

    v4Db.execute('''
      CREATE TABLE points_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        geometry_id INTEGER NOT NULL,
        properties_id INTEGER NOT NULL,
        deduplication_key TEXT NOT NULL UNIQUE,
        user_id INTEGER NOT NULL,
        is_uploaded INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (geometry_id) REFERENCES point_geometry_table(id),
        FOREIGN KEY (properties_id) REFERENCES point_properties_table(id),
        FOREIGN KEY (user_id) REFERENCES user_table(id)
      );
    ''');

    v4Db.execute('''
      CREATE TABLE track_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        active INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES user_table(id)
      );
    ''');

    v4Db.execute('''
      CREATE TABLE tracker_settings_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        tracking_interval INTEGER NOT NULL,
        distance_filter INTEGER NOT NULL,
        auto_tracking_enabled INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES user_table(id)
      );
    ''');

    v4Db.execute('''
      CREATE TABLE user_settings_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        FOREIGN KEY (user_id) REFERENCES user_table(id)
      );
    ''');

    // Set version to 4
    v4Db.execute('PRAGMA user_version = 4;');

    // Insert test data
    v4Db.execute('''
      INSERT INTO point_properties_table (
        battery_state, battery_level, wifi, timestamp,
        altitude, speed, horizontal_accuracy, vertical_accuracy,
        speed_accuracy, course, course_accuracy, track_id, device_id
      ) VALUES (
        'charging', 85.5, 'TestWiFi', 1234567890,
        100.0, 5.0, 10.0, 5.0,
        1.0, 180.0, 2.0, 'track-1', 'device-1'
      )
    ''');

    v4Db.dispose();

    // Open with SQLiteClient (triggers migration)
    final db = SQLiteClient.forTesting(DatabaseConnection(NativeDatabase(File(dbPath))));

    // Verify v5 schema
    final columns = await db.customSelect(
      "SELECT name FROM pragma_table_info('point_properties_table')"
    ).get();

    final columnNames = columns.map((c) => c.data['name'] as String).toList();

    expect(columnNames, contains('record_timestamp'),
        reason: 'record_timestamp column should exist after migration');
    expect(columnNames, contains('provider_timestamp'),
        reason: 'provider_timestamp column should exist after migration');
    expect(columnNames, isNot(contains('timestamp')),
        reason: 'timestamp column should be renamed');

    // Verify data was preserved
    final data = await db.customSelect(
      'SELECT record_timestamp, provider_timestamp FROM point_properties_table WHERE device_id = ?',
      variables: [Variable.withString('device-1')]
    ).getSingle();

    expect(data.data['record_timestamp'], equals(1234567890),
        reason: 'Data should be preserved in renamed column');
    expect(data.data['provider_timestamp'], equals(1234567890),
        reason: 'provider_timestamp should be backfilled from record_timestamp');

    await db.close();
  });


  test('can insert and query data in v5', () async {
    final dbPath = p.join(tempDir.path, 'test_v5.db');

    // Create fresh v5 database
    final db = SQLiteClient.forTesting(DatabaseConnection(NativeDatabase(File(dbPath))));

    // Insert test data using the current schema
    await db.customStatement('''
      INSERT INTO point_properties_table (
        battery_state, battery_level, wifi, record_timestamp, provider_timestamp,
        altitude, speed, horizontal_accuracy, vertical_accuracy,
        speed_accuracy, course, course_accuracy, track_id, device_id
      ) VALUES (
        'discharging', 75.0, 'MyWiFi', 1111111111, 1111111111,
        150.0, 8.0, 12.0, 6.0,
        1.5, 45.0, 2.5, 'track-3', 'device-3'
      )
    ''');

    // Query the data
    final result = await db.customSelect(
      'SELECT * FROM point_properties_table WHERE device_id = ?',
      variables: [Variable.withString('device-3')]
    ).getSingle();

    expect(result.data['battery_state'], equals('discharging'));
    expect(result.data['battery_level'], equals(75.0));
    expect(result.data['record_timestamp'], equals(1111111111));
    expect(result.data['provider_timestamp'], equals(1111111111));
    expect(result.data['altitude'], equals(150.0));

    await db.close();
  });
}
