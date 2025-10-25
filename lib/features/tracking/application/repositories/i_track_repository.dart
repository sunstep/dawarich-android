import 'package:dawarich/features/tracking/data/data_transfer_objects/track_dto.dart';
import 'package:option_result/option.dart';

abstract interface class ITrackRepository {
  Future<int> storeTrack(TrackDto track);
  Future<Option<TrackDto>> getActiveTrack(int userId);
  Future<void> stopTrack(TrackDto track);
}
