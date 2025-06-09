import 'package:dawarich/data_contracts/data_transfer_objects/track/track_dto.dart';
import 'package:option_result/option.dart';

abstract interface class ITrackRepository {
  Future<void> storeTrack(TrackDto track);
  Future<Option<TrackDto>> getActiveTrack(int userId);
  Future<void> stopTrack(TrackDto trackId);
}
