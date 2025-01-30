import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_properties.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_properties_dto.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_properties_viewmodel.dart';

extension PointPropertiesEntityToViewModel on PointProperties {

  PointPropertiesViewModel toViewModel() {
    return PointPropertiesViewModel(
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

extension PointPropertiesViewModelToEntity on PointPropertiesViewModel {

  PointProperties toEntity() {
    return PointProperties(
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

extension PointPropertiesDtoToEntity on PointPropertiesDto {

  PointProperties toEntity() {
    return PointProperties(
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



extension PointPropertiesToDto on PointProperties {

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

