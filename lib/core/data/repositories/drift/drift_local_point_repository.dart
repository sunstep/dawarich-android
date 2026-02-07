import 'package:dawarich/core/data/drift/database/sqlite_client.dart';
import 'package:dawarich/core/data/drift/extensions/mappers/point_mapper.dart';
import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import 'package:drift/drift.dart';

final class DriftPointLocalRepository implements IPointLocalRepository {
  final SQLiteClient _database;
  DriftPointLocalRepository(this._database);

  @override
  Future<int> storePoint(LocalPoint point) async {
    try {

      return await _database.transaction(() async {
        final int geometryId = await _database.into(_database.pointGeometryTable).insert(
          PointGeometryTableCompanion(
            type: Value(point.geometry.type),
            longitude: Value(point.geometry.longitude),
            latitude: Value(point.geometry.latitude),
          ),
        );

        final int propertiesId = await _database.into(_database.pointPropertiesTable).insert(
          PointPropertiesTableCompanion(
            batteryState: Value(point.properties.batteryState),
            batteryLevel: Value(point.properties.batteryLevel),
            wifi: Value(point.properties.wifi),
            recordTimestamp: Value(point.properties.recordTimestamp),
            providerTimestamp: Value(point.properties.providerTimestamp),
            horizontalAccuracy: Value(point.properties.horizontalAccuracy),
            verticalAccuracy: Value(point.properties.verticalAccuracy),
            altitude: Value(point.properties.altitude),
            speed: Value(point.properties.speed),
            speedAccuracy: Value(point.properties.speedAccuracy),
            course: Value(point.properties.course),
            courseAccuracy: Value(point.properties.courseAccuracy),
            trackId: const Value(null),
            deviceId: Value(point.properties.deviceId),
          ),
        );

        final int pointId = await _database.into(_database.pointsTable).insert(
          PointsTableCompanion(
            type: Value(point.type),
            geometryId: Value(geometryId),
            propertiesId: Value(propertiesId),
            deduplicationKey: Value(point.deduplicationKey),
            userId: Value(point.userId),
          ),
          mode: InsertMode.insertOrIgnore,
        );

        return pointId;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<LocalPoint>> getFullBatch(int userId) async {
    try {
      final query = _database.select(_database.pointsTable).join([
        innerJoin(
          _database.pointGeometryTable,
          _database.pointGeometryTable.id
              .equalsExp(_database.pointsTable.geometryId),
        ),
        innerJoin(
          _database.pointPropertiesTable,
          _database.pointPropertiesTable.id
              .equalsExp(_database.pointsTable.propertiesId),
        ),
      ])
        ..where(_database.pointsTable.userId.equals(userId));

      final List<LocalPoint> batchPoints =
          await query.map((row) => row.fromPointRow(_database)).get();

      return batchPoints;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Failed to retrieve batch points: $e");
      }
      rethrow;
    }
  }

  @override
  Future<List<LocalPoint>> getCurrentBatch(int userId) async {
    try {
      final query = _database.select(_database.pointsTable).join([
        innerJoin(
          _database.pointGeometryTable,
          _database.pointGeometryTable.id
              .equalsExp(_database.pointsTable.geometryId),
        ),
        innerJoin(
          _database.pointPropertiesTable,
          _database.pointPropertiesTable.id
              .equalsExp(_database.pointsTable.propertiesId),
        ),
      ])
        ..where(_database.pointsTable.isUploaded.equals(false) &
            _database.pointsTable.userId.equals(userId));

      final List<LocalPoint> batchPoints =
          await query.map((row) => row.fromPointRow(_database)).get();

      return batchPoints;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Failed to retrieve batch points: $e");
      }
      rethrow;
    }
  }

  @override
  Stream<List<LocalPoint>> watchCurrentBatch(int userId) {

    if (kDebugMode) {
      debugPrint("[DriftPointLocalRepository] Watching current batch for user $userId");
    }

    try {
      final query = _database.select(_database.pointsTable).join([
        innerJoin(
          _database.pointGeometryTable,
          _database.pointGeometryTable.id
              .equalsExp(_database.pointsTable.geometryId),
        ),
        innerJoin(
          _database.pointPropertiesTable,
          _database.pointPropertiesTable.id
              .equalsExp(_database.pointsTable.propertiesId),
        ),
      ])
        ..where(_database.pointsTable.isUploaded.equals(false) &
        _database.pointsTable.userId.equals(userId));

      return query.watch().distinct().map(
              (rows) => rows.map((r) => r.fromPointRow(_database)).toList());

    } catch (e) {
      if (kDebugMode) {
        debugPrint("Failed to retrieve batch points: $e");
      }
      return Stream.error(e);
    }


  }

  @override
  Future<Option<LastPoint>> getLastPoint(int userId) async {
    try {

      final JoinedSelectStatement queryResult =
      _database.select(_database.pointsTable).join([
        innerJoin(
          _database.pointGeometryTable,
          _database.pointGeometryTable.id
              .equalsExp(_database.pointsTable.geometryId),
        ),
        innerJoin(
          _database.pointPropertiesTable,
          _database.pointPropertiesTable.id
              .equalsExp(_database.pointsTable.propertiesId),
        ),
      ])
        ..orderBy([
          OrderingTerm(
              expression: _database.pointsTable.id, mode: OrderingMode.desc)
        ]) // Apply ordering last
        ..limit(1)
        ..where(_database.pointsTable.userId.equals(userId));

      LocalPoint? point =
      await queryResult.map((row) => row.fromPointRow(_database)).getSingleOrNull();

      if (point != null) {
        return Some(LastPoint(
            longitude: point.geometry.longitude,
            latitude: point.geometry.latitude,
            timestamp: point.properties.recordTimestamp));
      }

      return const None();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error retrieving last point: $e");
      }

      rethrow;
    }
  }

  @override
  Stream<Option<LastPoint>> watchLastPoint(int userId) {

    if (kDebugMode) {
      debugPrint("[DriftPointLocalRepository] Watching last point for user $userId");
    }

    try {
      final query = _database.select(_database.pointsTable).join([
        leftOuterJoin(
          _database.pointGeometryTable,
          _database.pointGeometryTable.id
              .equalsExp(_database.pointsTable.geometryId),
        ),
        leftOuterJoin(
          _database.pointPropertiesTable,
          _database.pointPropertiesTable.id
              .equalsExp(_database.pointsTable.propertiesId),
        ),
      ])
        ..orderBy([
          OrderingTerm(
              expression: _database.pointsTable.id, mode: OrderingMode.desc)
        ]) // Apply ordering last
        ..limit(1)
        ..where(_database.pointsTable.userId.equals(userId));

      return query.watchSingleOrNull().map((row) {

        if (row == null) {
          return const None();
        }

        // final point = row.readTable(_database.pointsTable);
        final geometry = row.readTable(_database.pointGeometryTable);
        final properties = row.readTable(_database.pointPropertiesTable);

        final point = LastPoint(
          longitude: geometry.longitude,
          latitude: geometry.latitude,
          timestamp: properties.recordTimestamp,
        );

        return Some(point);
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error watching last point: $e");
      }
      return Stream.error(e);
    }
  }


  @override
  Future<int> getBatchPointCount(int userId) async {
    try {
      final countQuery = await (_database.selectOnly(_database.pointsTable)
            ..addColumns([_database.pointsTable.id.count()])
            ..where(_database.pointsTable.isUploaded.equals(false) &
                _database.pointsTable.userId.equals(userId)))
          .getSingle();

      return countQuery.read(_database.pointsTable.id.count()) ?? 0;
    } catch (e) {
      debugPrint("Error fetching not uploaded points count: $e");
      rethrow;
    }
  }

  @override
  Stream<int> watchBatchPointCount(int userId) {

    if (kDebugMode) {
      debugPrint("[DriftPointLocalRepository] Watching batch point count for user $userId");
    }

    try {
      final query = _database.selectOnly(_database.pointsTable)
        ..addColumns([_database.pointsTable.id.count()])
        ..where(_database.pointsTable.isUploaded.equals(false) &
        _database.pointsTable.userId.equals(userId));

      return query.watchSingle().map((row) {
        return row.read(_database.pointsTable.id.count()) ?? 0;
      });
    } catch (e) {
      debugPrint("Error watching not uploaded points count: $e");
      return Stream.error(e);
    }
  }

  @override
  Future<int> markBatchAsUploaded(int userId, List<int> pointIds) async {
    try {
      final int rowsAffected = await (_database.update(_database.pointsTable)
            ..where((t) => 
                t.userId.equals(userId) &
                t.id.isIn(pointIds)
            )
      )
          .write(const PointsTableCompanion(isUploaded: Value(true)));

      return rowsAffected;
    } catch (e) {

      if (kDebugMode) {
        debugPrint("Failed to mark batch as uploaded: $e");
      }

      rethrow;
    }
  }

  @override
  Future<int> deletePoints(int userId, List<int> pointIds) async {

    if (pointIds.isEmpty) {
      return 0;
    }


    try {
      return await _database.transaction(() async {
        final pointRows = await (_database.select(_database.pointsTable)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.id.isIn(pointIds)))
            .get();

        final geometryIds = pointRows.map((p) => p.geometryId).toSet();
        final propertiesIds = pointRows.map((p) => p.propertiesId).toSet();

        final deletedCount = await (_database.delete(_database.pointsTable)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.id.isIn(pointIds)))
            .go();

        await (_database.delete(_database.pointGeometryTable)
          ..where((tbl) => tbl.id.isIn(geometryIds)))
            .go();

        await (_database.delete(_database.pointPropertiesTable)
          ..where((tbl) => tbl.id.isIn(propertiesIds)))
            .go();

        return deletedCount;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> clearBatch(int userId) async {
    try {
      final int deletedCount = await (_database.delete(_database.pointsTable)
            ..where(
                (t) => t.isUploaded.equals(false) & t.userId.equals(userId)))
          .go();

      return deletedCount;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> deleteUploadedPointsExceptLast(int userId) async {
    try {
      // Get the ID of the most recent point (regardless of upload status)
      final lastPointQuery = _database.select(_database.pointsTable)
        ..where((t) => t.userId.equals(userId))
        ..orderBy([(t) => OrderingTerm.desc(t.id)])
        ..limit(1);

      final lastPoint = await lastPointQuery.getSingleOrNull();

      if (lastPoint == null) {
        return 0; // No points to delete
      }

      final lastPointId = lastPoint.id;

      // Delete all uploaded points except the last one
      // Also delete their associated geometry and properties
      return await _database.transaction(() async {
        // Get IDs of points to delete (uploaded, not the last one)
        final pointsToDelete = await (_database.select(_database.pointsTable)
          ..where((t) =>
              t.userId.equals(userId) &
              t.isUploaded.equals(true) &
              t.id.isNotValue(lastPointId)))
          .get();

        if (pointsToDelete.isEmpty) {
          return 0;
        }

        final pointIds = pointsToDelete.map((p) => p.id).toList();
        final geometryIds = pointsToDelete.map((p) => p.geometryId).toList();
        final propertiesIds = pointsToDelete.map((p) => p.propertiesId).toList();

        // Delete points
        final deletedCount = await (_database.delete(_database.pointsTable)
          ..where((t) => t.id.isIn(pointIds)))
          .go();

        // Delete orphaned geometry and properties
        await (_database.delete(_database.pointGeometryTable)
          ..where((t) => t.id.isIn(geometryIds)))
          .go();

        await (_database.delete(_database.pointPropertiesTable)
          ..where((t) => t.id.isIn(propertiesIds)))
          .go();

        if (kDebugMode) {
          debugPrint("[PointRepo] Deleted $deletedCount old uploaded points, kept point $lastPointId");
        }

        return deletedCount;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("[PointRepo] Error deleting uploaded points: $e");
      }
      rethrow;
    }
  }
}
