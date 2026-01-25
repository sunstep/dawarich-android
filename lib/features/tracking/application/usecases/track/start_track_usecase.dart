
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/converters/track_converter.dart';
import 'package:dawarich/features/tracking/application/repositories/i_track_repository.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';
import 'package:session_box/session_box.dart';
import 'package:uuid/uuid.dart';

final class StartTrackUseCase {

  final ITrackRepository _trackRepository;
  final SessionBox<User> _userSession;

  StartTrackUseCase(this._trackRepository, this._userSession);

  Future<Track> call() async {

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

  Future<int> _requireUserId() async {
    final int? userId = _userSession.getUserId();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[TrackService] No user session found.');
    }
    return userId;
  }

}