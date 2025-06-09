import 'package:dawarich/domain/entities/point/batch/local/local_point_properties.dart';
import 'package:dawarich/ui/models/local/database/batch/local_point_properties_viewmodel.dart';

extension LocalPointPropertiesEntityToViewModel on LocalPointProperties {
  LocalPointPropertiesViewModel toViewModel() {
    return LocalPointPropertiesViewModel(
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

extension LocalPointPropertiesViewModelToEntity
    on LocalPointPropertiesViewModel {
  LocalPointProperties toEntity() {
    return LocalPointProperties(
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
