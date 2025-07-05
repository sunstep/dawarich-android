import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/upload/dawarich_point_properties_dto.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_properties.dart';

extension PointPropertiesDtoToEntity on DawarichPointPropertiesDto {
  DawarichPointProperties toDomain() {
    return DawarichPointProperties(
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

extension PointPropertiesToDto on DawarichPointProperties {
  DawarichPointPropertiesDto toDto() {
    return DawarichPointPropertiesDto(
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
