import 'package:dawarich/features/tracking/data/data_transfer_objects/track_dto.dart';
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
  Track toDomain() {
    return Track(
        id: id,
        trackId: trackId,
        startTime: startTime,
        endTime: endTime,
        active: active,
        userId: userId);
  }
}
