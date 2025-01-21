import 'package:dawarich/data/sources/api/v1/overland/batches/batches_client.dart';
import 'package:dawarich/data/sources/local/database/sqlite_client.dart' as sqlite;
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_properties_dto.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dawarich/data/sources/hardware/battery_data_client.dart';
import 'package:dawarich/data/sources/hardware/device_data_client.dart';
import 'package:dawarich/data/sources/hardware/gps_data_client.dart';
import 'package:dawarich/data/sources/hardware/wifi_data_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:option_result/option_result.dart';
import 'package:drift/drift.dart';


class LocalPointRepository implements ILocalPointInterfaces {

  final GpsDataClient _gpsDataClient;
  final DeviceDataClient _deviceDataClient;
  final BatteryDataSource _batteryDataClient;
  final WiFiDataClient _wiFiDataClient;
  final BatchesClient _batchesClient;

  final sqlite.SQLiteClient _database = sqlite.SQLiteClient();

  LocalPointRepository(this._gpsDataClient, this._deviceDataClient, this._batteryDataClient, this._wiFiDataClient, this._batchesClient);

  @override
  Future<Result<PointDto, String>> createPoint() async {

    Result<Position, String> positionResult = await _gpsDataClient.getPosition();

    if (positionResult case Ok(value: Position position)) {

      PointGeometryDto geometry = PointGeometryDto(type: "Point", coordinates: [position.longitude, position.latitude]);
      PointPropertiesDto pointProperties = PointPropertiesDto(
          timestamp: DateTime
              .now()
              .toUtc()
              .millisecondsSinceEpoch
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
          locationsInPayload: 0,
          deviceId: await _deviceDataClient.getDeviceId(),
          wifi: await _wiFiDataClient.getWiFiStatus(),
          batteryState: await _batteryDataClient.getBatteryState(),
          batteryLevel: await _batteryDataClient.getBatteryLevel()
      );

      return Ok(PointDto(type: "Feature", geometry: geometry, properties: pointProperties));
    }

    String error = positionResult.unwrapErr();
    return Err(error);
  }

  @override
  Future<Option<PointDto>> createCachedPoint() async {

    Option<Position> positionResult = await _gpsDataClient.getCachedPosition();

    if (positionResult case Some(value: Position position)) {
      PointGeometryDto geometry = PointGeometryDto(type: "Point", coordinates: [position.longitude, position.latitude]);
      PointPropertiesDto pointProperties = PointPropertiesDto(
          timestamp: DateTime
              .now()
              .toUtc()
              .millisecondsSinceEpoch
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
          locationsInPayload: 0,
          deviceId: await _deviceDataClient.getDeviceId(),
          wifi: await _wiFiDataClient.getWiFiStatus(),
          batteryState: await _batteryDataClient.getBatteryState(),
          batteryLevel: await _batteryDataClient.getBatteryLevel()
      );

      return Some(PointDto(type: "Feature", geometry: geometry, properties: pointProperties));
    }


    return const None();
  }

  @override
  Future<Result<void, String>> storePoint(PointDto point) async {
    try {
      await _database.into(_database.pointsTable).insert(
        sqlite.PointsTableCompanion(
          type: Value(point.type),
          geometryId: Value(await _storeGeometry(point.geometry)),
          propertiesId: Value(await _storeProperties(point.properties)),
        ),
      );
      return const Ok(null); // Indicate success
    } catch (e) {
      return Err("Failed to store point: $e");
    }
  }

  Future<int> _storeGeometry(PointGeometryDto geometry) async {
    return await _database.into(_database.pointGeometryTable).insert(
      sqlite.PointGeometryTableCompanion(
        type: Value(geometry.type),
        coordinates: Value(geometry.coordinates.join(',')), // Convert List to String
      ),
    );
  }

  Future<int> _storeProperties(PointPropertiesDto properties) async {
    return await _database.into(_database.pointPropertiesTable).insert(
      sqlite.PointPropertiesTableCompanion(
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
  Future<Result<void, String>> uploadBatch(PointBatchDto batch) async {

    Result<(), String> result = await _batchesClient.post(batch);

    switch (result) {
      case Ok(value: ()): {
        return const Ok(null);
      }
      case Err(value: String error): {
        debugPrint("Failed to upload batch: $error");
        return Err(error);
      }
    }
  }

}