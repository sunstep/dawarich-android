import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_properties.dart';
import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_properties_viewmodel.dart';
import 'package:intl/intl.dart';

extension PointPropertiesEntityToViewModel on OverlandPointProperties {

  OverlandPointPropertiesViewModel toViewModel() {

    DateTime parsedTimestamp = DateTime.parse(timestamp).toLocal();
    String formattedTimestamp = DateFormat('dd MMM yyyy HH:mm:ss').format(parsedTimestamp);

    double roundedSpeed = (speed * 100).round() / 100.0;


    return OverlandPointPropertiesViewModel(
        timestamp: formattedTimestamp,
        altitude: altitude,
        speed: roundedSpeed,
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

extension PointPropertiesViewModelToEntity on OverlandPointPropertiesViewModel {

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