import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_properties_dto.dart';
import 'package:drift/drift.dart';

extension PointMapper on TypedResult {
  LocalPointDto toPointDto(SQLiteClient database) {
    final pointRow = readTable(database.pointsTable);
    final propertiesRow = readTable(database.pointPropertiesTable);
    final geometryRow = readTable(database.pointGeometryTable);


    return LocalPointDto(
        id: pointRow.id,
        type: pointRow.type,
        geometry: LocalPointGeometryDto(
          type: geometryRow.type,
          longitude: geometryRow.longitude,
          latitude: geometryRow.latitude
        ),
        properties: LocalPointPropertiesDto(
          batteryState: propertiesRow.batteryState,
          batteryLevel: propertiesRow.batteryLevel,
          wifi: propertiesRow.wifi,
          timestamp: propertiesRow.timestamp.toUtc(),
          horizontalAccuracy: propertiesRow.horizontalAccuracy,
          verticalAccuracy: propertiesRow.verticalAccuracy,
          altitude: propertiesRow.altitude,
          speed: propertiesRow.speed,
          speedAccuracy: propertiesRow.speedAccuracy,
          course: propertiesRow.course,
          courseAccuracy: propertiesRow.courseAccuracy,
          trackId: propertiesRow.trackId,
          deviceId: propertiesRow.deviceId,
        ),
        userId: pointRow.userId,
        isUploaded: pointRow.isUploaded);
  }
}
