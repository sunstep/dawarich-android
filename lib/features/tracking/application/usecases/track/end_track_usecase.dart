import 'package:dawarich/features/tracking/application/repositories/i_track_repository.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/track_dto.dart';
import 'package:option_result/option.dart';

final class EndTrackUseCase {

  final ITrackRepository _trackRepository;

  EndTrackUseCase(this._trackRepository);

  Future<void> call(int userId) async {
    final DateTime endTime = DateTime.now().toUtc();

    Option<TrackDto> trackResult =
    await _trackRepository.getActiveTrack(userId);

    if (trackResult case Some(value: TrackDto trackDto)) {
      trackDto.setEndTime(endTime);
      await _trackRepository.stopTrack(trackDto);
    }
  }
}