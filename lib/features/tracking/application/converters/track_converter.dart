import 'package:dawarich/data_contracts/data_transfer_objects/track/track_dto.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';

extension TrackToDto on Track {
  TrackDto toDto() {
    return TrackDto(
        id: id,
        trackId: trackId,
        startTime: startTime,
        endTime: endTime,
        active: active,
        userId: userId);
  }
}

extension TrackDtoToEntity on TrackDto {
  Track toEntity() {
    return Track(
        id: id,
        trackId: trackId,
        startTime: startTime,
        endTime: endTime,
        active: active,
        userId: userId);
  }
}
