
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/properties.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/properties_dto.dart';

extension PropertiesToDto on Properties {

  PropertiesDto toDto() {

    return PropertiesDto(
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