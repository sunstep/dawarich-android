import 'package:dawarich/core/data/drift/database/sqlite_client.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/track_dto.dart';

extension TrackMapper on TrackTableData {
  TrackDto fromDatabase() {
    return TrackDto(
        id: id,
        trackId: trackId,
        startTime: startTimestamp,
        endTime: endTimestamp,
        active: active,
        userId: userId);
  }
}
