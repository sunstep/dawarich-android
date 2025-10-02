import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/converters/track_converter.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/track_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/i_track_repository.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';
import 'package:option_result/option.dart';
import 'package:session_box/session_box.dart';
import 'package:uuid/uuid.dart';

final class TrackService {
  final ITrackRepository _trackRepository;
  final SessionBox<User> _userSession;

  TrackService(this._trackRepository, this._userSession);

  Future<Track> startTracking() async {

    final int userId = await _requireUserId();

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

    final int userId = await _requireUserId();

    final DateTime endTime = DateTime.now().toUtc();

    Option<TrackDto> trackResult =
        await _trackRepository.getActiveTrack(userId);

    if (trackResult case Some(value: TrackDto trackDto)) {
      trackDto.setEndTime(endTime);
      await _trackRepository.stopTrack(trackDto);
    }
  }

  Future<Option<Track>> getActiveTrack() async {
    final int userId = await _requireUserId();

    Option<TrackDto> trackResult =
        await _trackRepository.getActiveTrack(userId);

    if (trackResult case Some(value: TrackDto trackDto)) {
      Track track = trackDto.toEntity();

      return Some(track);
    }

    return const None();
  }

  Future<int> _requireUserId() async {
    final int? userId = _userSession.getUserId();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[TrackService] No user session found.');
    }
    return userId;
  }
}
