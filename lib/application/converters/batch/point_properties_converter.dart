
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_properties.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_properties_dto.dart';

extension PropertiesToDto on PointProperties {

  PointPropertiesDto toDto() {

    return PointPropertiesDto(
        timestamp: timestamp,
        altitude: altitude,
        speed: speed,
        horizontalAccuracy: horizontalAccuracy,
        verticalAccuracy: verticalAccuracy,
        motion: motion,
        pauses: pauses,
        activity: activity,
        desiredAccuracy: desiredAccuracy,
        deferred: deferred,
        significantChange: significantChange,
        locationsInPayload: locationsInPayload,
        deviceId: deviceId,
        wifi: wifi,
        batteryState: batteryState,
        batteryLevel: batteryLevel
    );
  }
}