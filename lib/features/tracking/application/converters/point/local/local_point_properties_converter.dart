import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_properties.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';

extension LocalPointPropertiesToApi on LocalPointProperties {
  DawarichPointProperties toApi() {
    return DawarichPointProperties(
        batteryState: batteryState,
        batteryLevel: batteryLevel,
        wifi: wifi,
        timestamp: recordTimestamp,
        horizontalAccuracy: horizontalAccuracy,
        verticalAccuracy: verticalAccuracy,
        altitude: altitude,
        speed: speed,
        speedAccuracy: speedAccuracy,
        course: course,
        courseAccuracy: courseAccuracy,
        deviceId: deviceId);
  }
}
