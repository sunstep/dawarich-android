import 'package:dawarich/data/sources/api/v1/overland/batches/batches_wrapper.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_properties_dto.dart';
import 'package:dawarich/data_contracts/interfaces/point_creation_repository_interfaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dawarich/data/sources/hardware/battery_data_source.dart';
import 'package:dawarich/data/sources/hardware/device_data_source.dart';
import 'package:dawarich/data/sources/hardware/gps_source.dart';
import 'package:dawarich/data/sources/hardware/wifi_data_source.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:option_result/option_result.dart';

class PointCreationRepository implements IPointCreationInterfaces {

  final GpsDataSource _gpsDataSource;
  final DeviceDataSource _deviceDataSource;
  final BatteryDataSource _batteryDataSource;
  final WiFiDataSource _wiFiDataSource;
  final BatchesApiWrapper _batchesApiWrapper;

  PointCreationRepository(this._gpsDataSource, this._deviceDataSource, this._batteryDataSource, this._wiFiDataSource, this._batchesApiWrapper);

  @override
  Future<Result<PointDto, String>> createPoint() async {

    Result<Position, String> positionResult = await _gpsDataSource.getPosition();

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
          deviceId: await _deviceDataSource.getDeviceId(),
          wifi: await _wiFiDataSource.getWiFiStatus(),
          batteryState: await _batteryDataSource.getBatteryState(),
          batteryLevel: await _batteryDataSource.getBatteryLevel()
      );

      return Ok(PointDto(type: "Feature", geometry: geometry, properties: pointProperties));
    }

    String error = positionResult.unwrapErr();
    return Err(error);
  }

  @override
  Future<Option<PointDto>> createCachedPoint() async {

    Option<Position> positionResult = await _gpsDataSource.getCachedPosition();

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
          deviceId: await _deviceDataSource.getDeviceId(),
          wifi: await _wiFiDataSource.getWiFiStatus(),
          batteryState: await _batteryDataSource.getBatteryState(),
          batteryLevel: await _batteryDataSource.getBatteryLevel()
      );

      return Some(PointDto(type: "Feature", geometry: geometry, properties: pointProperties));
    }


    return const None();
  }

  @override
  Future<Result<(), String>> uploadBatch(PointBatchDto batch) async {

    Result<(), String> result = await _batchesApiWrapper.post(batch);

    switch (result) {
      case Ok(value: ()): {
        return const Ok(());
      }
      case Err(value: String error): {
        debugPrint("Failed to upload batch: $error");
        return Err(error);
      }
    }
  }

}