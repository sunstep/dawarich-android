
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/i_track_repository.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/track_dto.dart';
import 'package:option_result/option.dart';
import 'package:session_box/session_box.dart';

final class EndTrackUseCase {

  final ITrackRepository _trackRepository;
  final SessionBox<User> _userSession;

  EndTrackUseCase(this._trackRepository, this._userSession);

  Future<void> call() async {

    final int userId = await _requireUserId();

    final DateTime endTime = DateTime.now().toUtc();

    Option<TrackDto> trackResult =
    await _trackRepository.getActiveTrack(userId);

    if (trackResult case Some(value: TrackDto trackDto)) {
      trackDto.setEndTime(endTime);
      await _trackRepository.stopTrack(trackDto);
    }
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