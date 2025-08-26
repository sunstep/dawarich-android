import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_properties_dto.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_properties.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';

extension LocalPointPropertiesToDto on LocalPointProperties {
  LocalPointPropertiesDto toDto() {
    return LocalPointPropertiesDto(
      batteryState: batteryState,
      batteryLevel: batteryLevel,
      wifi: wifi,
      timestamp: timestamp.toIso8601String(),
      horizontalAccuracy: horizontalAccuracy,
      verticalAccuracy: verticalAccuracy,
      altitude: altitude,
      speed: speed,
      speedAccuracy: speedAccuracy,
      course: course,
      courseAccuracy: courseAccuracy,
      trackId: trackId,
      deviceId: deviceId,
    );
  }
}

extension LocalPointPropertiesToApi on LocalPointProperties {
  DawarichPointProperties toApi() {
    return DawarichPointProperties(
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
        deviceId: deviceId);
  }
}

extension LocalPointPropertiesDtoToEntity on LocalPointPropertiesDto {
  LocalPointProperties toDomain() {
    return LocalPointProperties(
      batteryState: batteryState,
      batteryLevel: batteryLevel,
      wifi: wifi,
      timestamp: DateTime.parse(timestamp),
      horizontalAccuracy: horizontalAccuracy,
      verticalAccuracy: verticalAccuracy,
      altitude: altitude,
      speed: speed,
      speedAccuracy: speedAccuracy,
      course: course,
      courseAccuracy: courseAccuracy,
      trackId: trackId,
      deviceId: deviceId,
    );
  }
}
