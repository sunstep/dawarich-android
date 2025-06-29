import 'package:dawarich/features/tracking/application/converters/track_converter.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/track_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/i_track_repository.dart';
import 'package:dawarich/core/session/domain/legacy_user_session_repository_interfaces.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';
import 'package:option_result/option.dart';
import 'package:user_session_manager/user_session_manager.dart';
import 'package:uuid/uuid.dart';

class TrackService {
  final ITrackRepository _trackRepository;
  final UserSessionManager<int> _userSession;

  TrackService(this._trackRepository, this._userSession);

  Future<Track> startTracking() async {

    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return null!;
    }

    final DateTime startTime = DateTime.now().toUtc();

    final String trackId = const Uuid().v4();

    final Track track = Track(
        id: 0,
        trackId: trackId,
        startTime: startTime,
        active: true,
        userId: userId);

    await _trackRepository.storeTrack(track.toDto());

    return track;
  }

  Future<void> stopTracking() async {

    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return;
    }

    final DateTime endTime = DateTime.now().toUtc();

    Option<TrackDto> trackResult =
        await _trackRepository.getActiveTrack(userId);

    if (trackResult case Some(value: TrackDto trackDto)) {
      trackDto.setEndTime(endTime);
      await _trackRepository.stopTrack(trackDto);
    }
  }

  Future<Option<Track>> getActiveTrack() async {
    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return const None();
    }

    Option<TrackDto> trackResult =
        await _trackRepository.getActiveTrack(userId);

    if (trackResult case Some(value: TrackDto trackDto)) {
      Track track = trackDto.toEntity();

      return Some(track);
    }

    return const None();
  }
}
