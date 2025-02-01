import 'dart:convert';
import 'package:dawarich/data/sources/local/database/extensions/mappers/point_mapper.dart';
import 'package:dawarich/data/sources/local/database/sqlite_client.dart';
import 'package:dawarich/data/sources/local/shared_preferences/tracker_preferences_client.dart';
import 'package:dawarich/data/sources/local/shared_preferences/user_storage_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/api_batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/batch_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/batch_point_properties_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/point_batch_dto.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dawarich/data/sources/hardware/battery_data_client.dart';
import 'package:dawarich/data/sources/hardware/device_data_client.dart';
import 'package:dawarich/data/sources/hardware/gps_data_client.dart';
import 'package:dawarich/data/sources/hardware/wifi_data_client.dart';
import 'package:option_result/option_result.dart';
import 'package:drift/drift.dart';


class LocalPointRepository implements ILocalPointInterfaces {

  final GpsDataClient _gpsDataClient;
  final DeviceDataClient _deviceDataClient;
  final BatteryDataSource _batteryDataClient;
  final WiFiDataClient _wiFiDataClient;

  final UserStorageClient _userStorageClient;
  final TrackerPreferencesClient _trackerPreferencesClient;

  final SQLiteClient _database = SQLiteClient();

  LocalPointRepository(
      this._gpsDataClient,
      this._deviceDataClient,
      this._batteryDataClient,
      this._wiFiDataClient,
      this._userStorageClient,
      this._trackerPreferencesClient
    );

  @override
  Future<Result<ApiBatchPointDto, String>> createPoint() async {

    Option<int> accuracyResult = await _trackerPreferencesClient.getLocationAccuracyPreference();

    LocationAccuracy accuracy = LocationAccuracy.high;

    if (accuracyResult case Some(value: int accuracyIndex)) {
      if (accuracyIndex >= 0 && accuracyIndex < LocationAccuracy.values.length) {
        LocationAccuracy.values[accuracyIndex];
      } else {
         LocationAccuracy.high;
      }
    }

    Result<Position, String> positionResult = await _gpsDataClient.getPosition(accuracy);

    if (positionResult case Ok(value: Position position)) {

      BatchPointGeometryDto geometry = BatchPointGeometryDto(type: "Point", coordinates: [position.longitude, position.latitude]);
      BatchPointPropertiesDto pointProperties = BatchPointPropertiesDto(
          timestamp: DateTime
              .now()
              .toUtc()
               // .millisecondsSinceEpoch Sadly the API does not play nice having this, so I'll keep this commented for now.
              .toString(),
          altitude: position.altitude,
          speed: position.speed,
          horizontalAccuracy: position.accuracy,
          verticalAccuracy: position.altitudeAccuracy,
          motion: [],
          pauses: false,
          activity: "",
          desiredAccuracy: 0.0,
          deferred: 0.0,
          significantChange: "",
          locationsInPayload: await getBatchPointCount(),
          deviceId: await _deviceDataClient.getDeviceId(),
          wifi: await _wiFiDataClient.getWiFiStatus(),
          batteryState: await _batteryDataClient.getBatteryState(),
          batteryLevel: await _batteryDataClient.getBatteryLevel()
      );

      return Ok(ApiBatchPointDto(type: "Feature", geometry: geometry, properties: pointProperties));
    }

    String error = positionResult.unwrapErr();
    return Err(error);
  }

  @override
  Future<Option<ApiBatchPointDto>> createCachedPoint() async {

    Option<Position> positionResult = await _gpsDataClient.getCachedPosition();

    if (positionResult case Some(value: Position position)) {
      BatchPointGeometryDto geometry = BatchPointGeometryDto(type: "Point", coordinates: [position.longitude, position.latitude]);
      BatchPointPropertiesDto pointProperties = BatchPointPropertiesDto(
          timestamp: DateTime
              .now()
              .toUtc()
              // .millisecondsSinceEpoch Sadly the API does not play nice having this, so I'll keep this commented for now.
              .toString(),
          altitude: position.altitude,
          speed: position.speed,
          horizontalAccuracy: position.accuracy,
          verticalAccuracy: position.altitudeAccuracy,
          motion: [],
          pauses: false,
          activity: "",
          desiredAccuracy: 0.0,
          deferred: 0.0,
          significantChange: "",
          locationsInPayload: await getBatchPointCount(),
          deviceId: await _deviceDataClient.getDeviceId(),
          wifi: await _wiFiDataClient.getWiFiStatus(),
          batteryState: await _batteryDataClient.getBatteryState(),
          batteryLevel: await _batteryDataClient.getBatteryLevel()
      );

      return Some(ApiBatchPointDto(type: "Feature", geometry: geometry, properties: pointProperties));
    }


    return const None();
  }

  @override
  Future<Result<void, String>> storePoint(ApiBatchPointDto point) async {
    try {
      await _database.into(_database.pointsTable).insert(
        PointsTableCompanion(
          type: Value(point.type),
          geometryId: Value(await _storeGeometry(point.geometry)),
          propertiesId: Value(await _storeProperties(point.properties)),
          userId: Value(await _userStorageClient.getLoggedInUserId()),
        )
      );
      return const Ok(null); // Indicate success
    } catch (e) {
      return Err("Failed to store point: $e");
    }
  }

  Future<int> _storeGeometry(BatchPointGeometryDto geometry) async {
    return await _database.into(_database.pointGeometryTable).insert(
      PointGeometryTableCompanion(
        type: Value(geometry.type),
        coordinates: Value(geometry.coordinates.join(',')), // Convert List to String
      ),
    );
  }

  Future<int> _storeProperties(BatchPointPropertiesDto properties) async {
    return await _database.into(_database.pointPropertiesTable).insert(
      PointPropertiesTableCompanion(
        timestamp: Value(properties.timestamp),
        altitude: Value(properties.altitude),
        speed: Value(properties.speed),
        horizontalAccuracy: Value(properties.horizontalAccuracy),
        verticalAccuracy: Value(properties.verticalAccuracy),
        motion: Value(properties.motion.join(',')), // Convert List to String
        pauses: Value(properties.pauses),
        activity: Value(properties.activity),
        desiredAccuracy: Value(properties.desiredAccuracy),
        deferred: Value(properties.deferred),
        significantChange: Value(properties.significantChange),
        locationsInPayload: Value(properties.locationsInPayload),
        deviceId: Value(properties.deviceId),
        wifi: Value(properties.wifi),
        batteryState: Value(properties.batteryState),
        batteryLevel: Value(properties.batteryLevel),
      ),
    );
  }

  @override
  Future<Option<BatchPointDto>> getLastPoint() async {
    try {
      // Query the last point stored in the PointsTable, based on the auto-incrementing ID.
      final int userId = await _userStorageClient.getLoggedInUserId();

      final queryResult = _database.select(_database.pointsTable)
        .join([
          innerJoin(
            _database.pointGeometryTable,
            _database.pointGeometryTable.id.equalsExp(_database.pointsTable.geometryId),
          ),
          innerJoin(
            _database.pointPropertiesTable,
            _database.pointPropertiesTable.id.equalsExp(_database.pointsTable.propertiesId),
          ),
        ])
        ..orderBy([OrderingTerm(expression: _database.pointsTable.id, mode: OrderingMode.desc)]) // Apply ordering last
        ..limit(1)
        ..where(_database.pointsTable.userId.equals(userId));

      return Some(await queryResult.map((row) => row.toPointDto(_database))
          .getSingle());


    } catch (e) {

      if (kDebugMode) {
        debugPrint("Error retrieving last point: $e");
      }

      return const None();
    }
  }

  @override
  Future<PointBatchDto> getCurrentBatch() async {

    try {
      final query = _database.select(_database.pointsTable).join([
        innerJoin(
          _database.pointGeometryTable,
          _database.pointGeometryTable.id.equalsExp(_database.pointsTable.geometryId),
        ),
        innerJoin(
          _database.pointPropertiesTable,
          _database.pointPropertiesTable.id.equalsExp(_database.pointsTable.propertiesId),
        ),
      ])
        ..where(_database.pointsTable.isUploaded.equals(false) & _database.pointsTable.userId.equals(await _userStorageClient.getLoggedInUserId()));

      final List<BatchPointDto> batchPoints = await query.map((row) => row.toPointDto(_database))
          .get();

      return PointBatchDto(points: batchPoints);
    } catch (e) {
      throw Exception("Failed to retrieve batch points: $e");
    }
  }

  @override
  Future<int> getBatchPointCount() async {
    try {

      final countQuery = await (_database.selectOnly(_database.pointsTable)
        ..addColumns([_database.pointsTable.id.count()])
        ..where(_database.pointsTable.isUploaded.equals(false)))
          .getSingle();

      return countQuery.read(_database.pointsTable.id.count()) ?? 0;
    } catch (e) {
      debugPrint("Error fetching not uploaded points count: $e");
      return 0;
    }
  }

  @override
  Future<bool> isDuplicatePoint(BatchPointDto point) async {
    final String serializedCoordinates = jsonEncode(point.geometry.coordinates);

    final count = await (_database.selectOnly(_database.pointsTable)
      ..addColumns([_database.pointsTable.id])
      ..join([
        innerJoin(
          _database.pointPropertiesTable,
          _database.pointPropertiesTable.id.equalsExp(_database.pointsTable.propertiesId),
        ),
        innerJoin(
          _database.pointGeometryTable,
          _database.pointGeometryTable.id.equalsExp(_database.pointsTable.geometryId),
        ),
      ])
      ..where(
        _database.pointPropertiesTable.timestamp.equals(point.properties.timestamp) &
        _database.pointGeometryTable.coordinates.equals(serializedCoordinates),
      )
      ..limit(1))
        .get();

    return count.isNotEmpty;
  }

  @override
  Future<Result<int, String>> markBatchAsUploaded(List<int> batchIds) async {
    try {

      int rowsAffected = await (_database
        .update(_database.pointsTable)
          ..where((t) => t.id.isIn(batchIds)))
        .write(const PointsTableCompanion(isUploaded: Value(true)));

      return Ok(rowsAffected);
    } catch (e) {
      return Err("Failed to mark batch as uploaded: $e");
    }
  }

  @override
  Future<Result<void, String>> deletePoint(int pointId) async {
    try {
      final int userId = await _userStorageClient.getLoggedInUserId();

      final deletedCount = await (_database.delete(_database.pointsTable)
        ..where((t) => t.id.equals(pointId) & t.userId.equals(userId))
      ).go();

      if (deletedCount == 0) {
        return const Err("Point not found.");
      }

      return const Ok(null);
    } catch (e) {
      return Err("Failed to delete point: $e");
    }
  }

  @override
  Future<Result<void, String>> clearBatch() async {
    try {
      final int userId = await _userStorageClient.getLoggedInUserId();

      await (_database.delete(_database.pointsTable)
        ..where((t) => t.isUploaded.equals(false) & t.userId.equals(userId))
      ).go();

      return const Ok(null);
    } catch (e) {
      return Err("Failed to clear batch: $e");
    }
  }

}