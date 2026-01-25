import 'package:dawarich/features/tracking/application/converters/track_converter.dart';
import 'package:dawarich/features/tracking/application/repositories/i_track_repository.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';
import 'package:uuid/uuid.dart';

final class StartTrackUseCase {

  final ITrackRepository _trackRepository;

  StartTrackUseCase(this._trackRepository);

  Future<Track> call(int userId) async {
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

}