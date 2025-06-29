import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/track/track_dto.dart';

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
