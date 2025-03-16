
import 'package:dawarich/application/converters/track_converter.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/track/track_dto.dart';
import 'package:dawarich/data_contracts/interfaces/track_repository.dart';
import 'package:dawarich/data_contracts/interfaces/user_session_repository_interfaces.dart';
import 'package:dawarich/domain/entities/track/track.dart';
import 'package:option_result/option.dart';
import 'package:uuid/uuid.dart';

class TrackService {

  final ITrackRepository _trackRepository;
  final IUserSessionRepository _userSession;

  TrackService(this._trackRepository, this._userSession);

  Future<Track> startTracking() async {

    final DateTime startTime = DateTime
      .now()
      .toUtc();

    final String trackId = const Uuid().v4();

    final Track track = Track(
      id: 0,
      trackId: trackId,
      startTime: startTime,
      active: true,
      userId: await _userSession.getCurrentUserId()
    );

    await _trackRepository.storeTrack(track.toDto());

    return track;
  }

  Future<void> stopTracking() async {

    final DateTime endTime = DateTime
        .now()
        .toUtc();

    final int userId = await _userSession.getCurrentUserId();
    Option<TrackDto> trackResult = await _trackRepository.getActiveTrack(userId);

    if (trackResult case Some(value: TrackDto trackDto)) {
      trackDto.setEndTime(endTime);
      await _trackRepository.stopTrack(trackDto);
    }

  }

  Future<Option<Track>> getActiveTrack() async {

    final int userId = await _userSession.getCurrentUserId();
    Option<TrackDto> trackResult = await _trackRepository.getActiveTrack(userId);

    if (trackResult case Some(value: TrackDto trackDto)) {
      Track track = trackDto.toEntity();

      return Some(track);
    }

    return const None();
  }
}