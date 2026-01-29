import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';
import 'package:dawarich/features/batch/presentation/models/local_point_properties_viewmodel.dart';

extension LocalPointPropertiesDomainToViewModel on LocalPointProperties {
  LocalPointPropertiesViewModel toViewModel() {
    return LocalPointPropertiesViewModel(
      batteryState: batteryState,
      batteryLevel: batteryLevel,
      wifi: wifi,
      timestamp: recordTimestamp.toLocal().toIso8601String(),
      providerTimestamp: providerTimestamp.toLocal().toIso8601String(),
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

extension LocalPointPropertiesViewModelToDomain
    on LocalPointPropertiesViewModel {
  LocalPointProperties toDomain() {
    return LocalPointProperties(
      batteryState: batteryState,
      batteryLevel: batteryLevel,
      wifi: wifi,
      recordTimestamp: DateTime.parse(timestamp).toUtc(),
      providerTimestamp: DateTime.parse(providerTimestamp).toUtc(),
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
