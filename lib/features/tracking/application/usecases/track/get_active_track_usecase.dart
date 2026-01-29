import 'package:dawarich/features/tracking/application/converters/track_converter.dart';
import 'package:dawarich/features/tracking/application/repositories/i_track_repository.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/track_dto.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';
import 'package:option_result/option.dart';

final class GetActiveTrackUseCase {

  final ITrackRepository _trackRepository;

  GetActiveTrackUseCase(this._trackRepository);

  Future<Option<Track>> call(int userId) async {
    Option<TrackDto> trackResult =
    await _trackRepository.getActiveTrack(userId);

    if (trackResult case Some(value: TrackDto trackDto)) {
      Track track = trackDto.toEntity();

      return Some(track);
    }

    return const None();
  }

}