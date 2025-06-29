import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_properties_dto.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_properties.dart';

extension PointPropertiesDtoToEntity on DawarichPointPropertiesDto {
  DawarichPointProperties toEntity() {
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
      trackId: trackId,
      deviceId: deviceId,
    );
  }
}

extension PointPropertiesToDto on DawarichPointProperties {
  DawarichPointPropertiesDto toDto() {
    return DawarichPointPropertiesDto(
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
      trackId: trackId,
      deviceId: deviceId,
    );
  }
}
