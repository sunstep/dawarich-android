import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_properties.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_properties_viewmodel.dart';

extension PointPropertiesDtoToEntity on OverlandPointPropertiesViewModel {

  OverlandPointProperties toEntity() {
    return OverlandPointProperties(
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

extension PointPropertiesToViewModel on OverlandPointProperties {

  OverlandPointPropertiesViewModel toViewModel() {

    return OverlandPointPropertiesViewModel(
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

