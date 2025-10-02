import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';
import 'package:dawarich/features/batch/presentation/models/local_point_properties_viewmodel.dart';

extension LocalPointPropertiesEntityToViewModel on LocalPointProperties {
  LocalPointPropertiesViewModel toViewModel() {
    return LocalPointPropertiesViewModel(
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

extension LocalPointPropertiesViewModelToEntity
    on LocalPointPropertiesViewModel {
  LocalPointProperties toDomain() {
    return LocalPointProperties(
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
