import 'package:dawarich/domain/entities/track/track.dart';
import 'package:dawarich/ui/models/track/track_viewmodel.dart';

extension TrackToViewModel on Track {

  TrackViewModel toViewModel() {
    return TrackViewModel(
      id: id,
      trackId: trackId,
      startTime: startTime,
      endTime: endTime,
      active: active,
      userId: userId
    );
  }
}

extension TrackViewModelToEntity on TrackViewModel {

  Track toEntity() {
    return Track(
      id: id,
      trackId: trackId,
      startTime: startTime,
      endTime: endTime,
      active: active,
      userId: userId
    );
  }
}