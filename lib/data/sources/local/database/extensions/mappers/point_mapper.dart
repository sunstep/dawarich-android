
import 'package:dawarich/data/sources/local/database/sqlite_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/batch_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/batch_point_properties_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/batch_point_dto.dart';
import 'package:drift/drift.dart';

extension PointMapper on TypedResult {

  BatchPointDto toPointDto(SQLiteClient database) {
    final pointRow = readTable(database.pointsTable);
    final propertiesRow = readTable(database.pointPropertiesTable);
    final geometryRow = readTable(database.pointGeometryTable);

    final coordinates = geometryRow.coordinates.split(',');
    if (coordinates.length != 2) {
      throw Exception("Invalid coordinates format: ${geometryRow.coordinates}");
    }
    final longitude = double.parse(coordinates[0]);
    final latitude = double.parse(coordinates[1]);

    return BatchPointDto(
      id: pointRow.id,
      type: pointRow.type,
      geometry: BatchPointGeometryDto(
        type: geometryRow.type,
        coordinates: [longitude, latitude],
      ),
      properties: BatchPointPropertiesDto(
        timestamp: propertiesRow.timestamp,
        altitude: propertiesRow.altitude,
        speed: propertiesRow.speed,
        horizontalAccuracy: propertiesRow.horizontalAccuracy,
        verticalAccuracy: propertiesRow.verticalAccuracy,
        motion: propertiesRow.motion.split(','),
        pauses: propertiesRow.pauses,
        activity: propertiesRow.activity,
        desiredAccuracy: propertiesRow.desiredAccuracy,
        deferred: propertiesRow.deferred,
        significantChange: propertiesRow.significantChange,
        locationsInPayload: propertiesRow.locationsInPayload,
        deviceId: propertiesRow.deviceId,
        wifi: propertiesRow.wifi,
        batteryState: propertiesRow.batteryState,
        batteryLevel: propertiesRow.batteryLevel,
      ),
    );
  }
}