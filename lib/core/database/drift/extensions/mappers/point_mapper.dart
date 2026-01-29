import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';
import 'package:drift/drift.dart';

extension PointMapper on TypedResult {
  LocalPoint fromPointRow(SQLiteClient database) {
    final pointRow = readTable(database.pointsTable);
    final propertiesRow = readTable(database.pointPropertiesTable);
    final geometryRow = readTable(database.pointGeometryTable);


    return LocalPoint(
        id: pointRow.id,
        type: pointRow.type,
        geometry: LocalPointGeometry(
          type: geometryRow.type,
          longitude: geometryRow.longitude,
          latitude: geometryRow.latitude
        ),
        properties: LocalPointProperties(
          batteryState: propertiesRow.batteryState,
          batteryLevel: propertiesRow.batteryLevel,
          wifi: propertiesRow.wifi,
          recordTimestamp: propertiesRow.recordTimestamp.toUtc(),
          providerTimestamp: propertiesRow.providerTimestamp.toUtc(),
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
