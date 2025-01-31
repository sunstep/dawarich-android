import 'package:dawarich/domain/entities/api/v1/overland/batches/request/batch_point_properties.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/batch_point_properties_viewmodel.dart';

extension PointPropertiesEntityToViewModel on BatchPointProperties {

  BatchPointPropertiesViewModel toViewModel() {
    return BatchPointPropertiesViewModel(
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

extension PointPropertiesViewModelToEntity on BatchPointPropertiesViewModel {

  BatchPointProperties toEntity() {
    return BatchPointProperties(
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