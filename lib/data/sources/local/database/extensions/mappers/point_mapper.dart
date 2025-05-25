import 'package:dawarich/data/sources/local/database/sqlite_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_properties_dto.dart';
import 'package:drift/drift.dart';

extension PointMapper on TypedResult {

  LocalPointDto toPointDto(SQLiteClient database) {
    final pointRow = readTable(database.pointsTable);
    final propertiesRow = readTable(database.pointPropertiesTable);
    final geometryRow = readTable(database.pointGeometryTable);

    final coordinates = geometryRow.coordinates.split(',');
    if (coordinates.length != 2) {
      throw Exception("Invalid coordinates format: ${geometryRow.coordinates}");
    }
    final longitude = double.parse(coordinates[0]);
    final latitude = double.parse(coordinates[1]);

    return LocalPointDto(
      id: pointRow.id,
      type: pointRow.type,
      geometry: LocalPointGeometryDto(
        type: geometryRow.type,
        coordinates: [longitude, latitude],
      ),
      properties: LocalPointPropertiesDto(
        batteryState: propertiesRow.batteryState,
        batteryLevel: propertiesRow.batteryLevel,
        wifi: propertiesRow.wifi,
        timestamp: propertiesRow.timestamp,
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
      isUploaded: pointRow.isUploaded
    );
  }
}