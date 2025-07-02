import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/database/drift/extensions/mappers/point_mapper.dart';
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_properties_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/last_point_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import 'package:drift/drift.dart';

final class DriftPointLocalRepository implements IPointLocalRepository {
  final SQLiteClient _database;
  DriftPointLocalRepository(this._database);

  @override
  Future<int> storePoint(LocalPointDto point) async {
    try {
      final int pointId = await _database.into(_database.pointsTable).insert(PointsTableCompanion(
            type: Value(point.type),
            geometryId: Value(await _storeGeometry(point.geometry)),
            propertiesId: Value(await _storeProperties(point.properties)),
            userId: Value(point.userId),
          ));
      return pointId;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> _storeGeometry(LocalPointGeometryDto geometry) async {
    return await _database.into(_database.pointGeometryTable).insert(
          PointGeometryTableCompanion(
            type: Value(geometry.type),
            coordinates:
                Value(geometry.coordinates.join(',')), // Convert List to String
          ),
        );
  }

  Future<int> _storeProperties(LocalPointPropertiesDto properties) async {
    return await _database.into(_database.pointPropertiesTable).insert(
          PointPropertiesTableCompanion(
            batteryState: Value(properties.batteryState),
            batteryLevel: Value(properties.batteryLevel),
            wifi: Value(properties.wifi),
            timestamp: Value(properties.timestamp),
            horizontalAccuracy: Value(properties.horizontalAccuracy),
            verticalAccuracy: Value(properties.verticalAccuracy),
            altitude: Value(properties.altitude),
            speed: Value(properties.speed),
            speedAccuracy: Value(properties.speedAccuracy),
            course: Value(properties.course),
            courseAccuracy: Value(properties.courseAccuracy),
            trackId: const Value(null),
            deviceId: Value(properties.deviceId),
          ),
        );
  }

  @override
  Future<List<LocalPointDto>> getFullBatch(int userId) async {
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

      final List<LocalPointDto> batchPoints =
          await query.map((row) => row.toPointDto(_database)).get();

      return batchPoints;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Failed to retrieve batch points: $e");
      }
      rethrow;
    }
  }

  @override
  Future<List<LocalPointDto>> getCurrentBatch(int userId) async {
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

      final List<LocalPointDto> batchPoints =
          await query.map((row) => row.toPointDto(_database)).get();

      return batchPoints;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Failed to retrieve batch points: $e");
      }
      rethrow;
    }
  }

  @override
  Stream<List<LocalPointDto>> watchCurrentBatch(int userId) {
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
              (rows) => rows.map((r) => r.toPointDto(_database)).toList());

    } catch (e) {
      if (kDebugMode) {
        debugPrint("Failed to retrieve batch points: $e");
      }
      rethrow;
    }


  }

  @override
  Future<Option<LastPointDto>> getLastPoint(int userId) async {
    try {
      // Query the last point stored in the PointsTable, based on the auto-incrementing ID.

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

      LocalPointDto? point =
      await queryResult.map((row) => row.toPointDto(_database)).getSingleOrNull();

      if (point != null) {
        return Some(LastPointDto(
            longitude: point.geometry.coordinates[0],
            latitude: point.geometry.coordinates[1],
            timestamp: point.properties.timestamp));
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
  Future<int> markBatchAsUploaded(int userId) async {
    try {
      final int rowsAffected = await (_database.update(_database.pointsTable)
            ..where((t) => t.userId.equals(userId)))
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
  Future<int> deletePoint(int userId, int pointId) async {
    try {
      final int deletedCount = await (_database.delete(_database.pointsTable)
            ..where((t) => t.id.equals(pointId) & t.userId.equals(userId)))
          .go();


      return deletedCount;
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
}
