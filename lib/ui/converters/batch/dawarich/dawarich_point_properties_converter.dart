import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_properties.dart';
import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_properties_viewmodel.dart';

extension PointPropertiesToViewModel on DawarichPointProperties {
  DawarichPointPropertiesViewModel toViewModel() {
    return DawarichPointPropertiesViewModel(
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

extension PointPropertiesDtoToEntity on DawarichPointPropertiesViewModel {
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
