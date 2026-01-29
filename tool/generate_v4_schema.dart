import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Helper script to generate schema files for version 4
/// This creates a v4 database that can be used for testing migrations
void main() async {
  if (kDebugMode) {
    print('Creating v4 database for testing...');
  }

  final tempDir = Directory.systemTemp.createTempSync('drift_v4_');
  final dbPath = p.join(tempDir.path, 'test_v4.db');

  try {
    // Create v4 database schema manually
    final db = NativeDatabase(File(dbPath));

    // Create tables as they were in v4
    await db.runCustom('''
      CREATE TABLE user_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        dawarich_endpoint TEXT NOT NULL,
        dawarich_api_key TEXT NOT NULL,
        UNIQUE(email, dawarich_endpoint)
      );
    ''');

    await db.runCustom('''
      CREATE TABLE user_settings_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        FOREIGN KEY (user_id) REFERENCES user_table(id)
      );
    ''');

    await db.runCustom('''
      CREATE TABLE point_geometry_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        longitude REAL NOT NULL,
        latitude REAL NOT NULL
      );
    ''');

    await db.runCustom('''
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

    await db.runCustom('''
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

    await db.runCustom('''
      CREATE TABLE track_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        active INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES user_table(id)
      );
    ''');

    await db.runCustom('''
      CREATE TABLE tracker_settings_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        tracking_interval INTEGER NOT NULL,
        distance_filter INTEGER NOT NULL,
        auto_tracking_enabled INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES user_table(id)
      );
    ''');

    // Set version to 4
    await db.runCustom('PRAGMA user_version = 4;');

    if (kDebugMode) {
      print('✅ V4 database created successfully at: $dbPath');
      print('');
      print('Now you can use drift_dev to export this schema:');
      print('dart run drift_dev schema dump $dbPath drift_schemas/drift_schema_v4.json');
    }

    await db.close();
  } catch (e, stack) {
    if (kDebugMode) {
      print('❌ Error creating v4 database: $e');
      print(stack);
    }

    exit(1);
  } finally {
    // Don't clean up - we need the file for drift_dev to read
    if (kDebugMode) {
      print('');
      print('Temp directory: ${tempDir.path}');
    }

  }
}
