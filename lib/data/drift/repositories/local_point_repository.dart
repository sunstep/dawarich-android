import 'package:dawarich/data/drift/extensions/mappers/point_mapper.dart';
import 'package:dawarich/data/drift/database/sqlite_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_properties_dto.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import 'package:drift/drift.dart';

final class LocalPointRepository implements ILocalPointRepository {
  final SQLiteClient _database;
  LocalPointRepository(this._database);

  @override
  Future<Result<(), String>> storePoint(LocalPointDto point) async {
    try {
      await _database.into(_database.pointsTable).insert(PointsTableCompanion(
            type: Value(point.type),
            geometryId: Value(await _storeGeometry(point.geometry)),
            propertiesId: Value(await _storeProperties(point.properties)),
            userId: Value(point.userId),
          ));
      return const Ok(());
    } catch (e) {
      return Err("Failed to store point: $e");
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

      LocalPointDto point =
          await queryResult.map((row) => row.toPointDto(_database)).getSingle();

      return Some(LastPointDto(
          longitude: point.geometry.coordinates[0],
          latitude: point.geometry.coordinates[1],
          timestamp: point.properties.timestamp));
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error retrieving last point: $e");
      }

      return const None();
    }
  }

  @override
  Future<Result<LocalPointBatchDto, String>> getFullBatch(int userId) async {
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

      return Ok(LocalPointBatchDto(points: batchPoints));
    } catch (e) {
      return Err("Failed to retrieve batch points: $e");
    }
  }

  @override
  Future<Result<LocalPointBatchDto, String>> getCurrentBatch(int userId) async {
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

      return Ok(LocalPointBatchDto(points: batchPoints));
    } catch (e) {
      return Err("Failed to retrieve batch points: $e");
    }
  }

  @override
  Future<Result<int, String>> getBatchPointCount(int userId) async {
    try {
      final countQuery = await (_database.selectOnly(_database.pointsTable)
            ..addColumns([_database.pointsTable.id.count()])
            ..where(_database.pointsTable.isUploaded.equals(false) &
                _database.pointsTable.userId.equals(userId)))
          .getSingle();

      return Ok(countQuery.read(_database.pointsTable.id.count()) ?? 0);
    } catch (e) {
      debugPrint("Error fetching not uploaded points count: $e");
      return Err("Failed to get point count of batch: $e");
    }
  }

  @override
  Future<Result<int, String>> markBatchAsUploaded(
      List<int> batchIds, int userId) async {
    try {
      final int rowsAffected = await (_database.update(_database.pointsTable)
            ..where((t) => t.id.isIn(batchIds) & t.userId.equals(userId)))
          .write(const PointsTableCompanion(isUploaded: Value(true)));

      return Ok(rowsAffected);
    } catch (e) {
      return Err("Failed to mark batch as uploaded: $e");
    }
  }

  @override
  Future<Result<(), String>> deletePoint(int pointId, int userId) async {
    try {
      final int deletedCount = await (_database.delete(_database.pointsTable)
            ..where((t) => t.id.equals(pointId) & t.userId.equals(userId)))
          .go();

      if (deletedCount == 0) {
        return const Err("Point not found.");
      }

      return const Ok(());
    } catch (e) {
      return Err("Failed to delete point: $e");
    }
  }

  @override
  Future<Result<(), String>> clearBatch(int userId) async {
    try {
      await (_database.delete(_database.pointsTable)
            ..where(
                (t) => t.isUploaded.equals(false) & t.userId.equals(userId)))
          .go();

      return const Ok(());
    } catch (e) {
      return Err("Failed to clear batch: $e");
    }
  }
}
