

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracker_settings_dto.freezed.dart';
part 'tracker_settings_dto.g.dart';

@freezed
abstract class TrackerSettingsDto with _$TrackerSettingsDto {

  const factory TrackerSettingsDto({
    required int userId,
    bool? automaticTracking,
    int? trackingFrequency,
    int? locationAccuracy,
    int? minimumPointDistance,
    int? pointsPerBatch,
    String? deviceId,
  }) = _TrackerSettingsDto;

  factory TrackerSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$TrackerSettingsDtoFromJson(json);

  static TrackerSettingsDto empty(int userId) => TrackerSettingsDto(
    userId: userId,
    automaticTracking: null,
    trackingFrequency: null,
    locationAccuracy: null,
    minimumPointDistance: null,
    pointsPerBatch: null,
    deviceId: null,
  );

}