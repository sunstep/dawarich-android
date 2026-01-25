
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/converters/track_converter.dart';
import 'package:dawarich/features/tracking/application/repositories/i_track_repository.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/track_dto.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';
import 'package:option_result/option.dart';
import 'package:session_box/session_box.dart';

final class GetActiveTrackUseCase {

  final ITrackRepository _trackRepository;
  final SessionBox<User> _userSession;

  GetActiveTrackUseCase(this._trackRepository, this._userSession);

  Future<Option<Track>> call() async {
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