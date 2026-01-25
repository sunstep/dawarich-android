


import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';

LocalPoint makeLocalPoint({
  required double longitude,
  required double latitude,
  required String batteryState,
  required double batteryLevel,
  required String wifi,
  required DateTime timestamp,
  required double horizontalAccuracy,
  required double verticalAccuracy,
  required double altitude,
  required double speed,
  required double speedAccuracy,
  required double course,
  required double courseAccuracy,
  required String deviceId,
  required int userId
}) {
  
  final LocalPointGeometry geometry = LocalPointGeometry(
      type: 'Point',
      longitude: longitude, 
      latitude: latitude
  );
  
  final LocalPointProperties properties = LocalPointProperties(
      batteryState: batteryState, 
      batteryLevel: batteryLevel, 
      wifi: wifi, 
      timestamp: timestamp, 
      horizontalAccuracy: horizontalAccuracy, 
      verticalAccuracy: verticalAccuracy, 
      altitude: altitude, 
      speed: speed, 
      speedAccuracy: speedAccuracy, 
      course: course, 
      courseAccuracy: courseAccuracy, 
      deviceId: deviceId
  );
  
  return LocalPoint(
      id: 0,
      type: 'Feature',
      geometry: geometry,
      properties: properties,
      userId: userId,
      isUploaded: false
  );
}