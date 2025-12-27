
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/converters/point/local/local_point_converter.dart';
import 'package:session_box/session_box.dart';

final class WatchCurrentBatchUseCase {

  final IPointLocalRepository _localPointRepository;
  final SessionBox<User> _userSession;
  WatchCurrentBatchUseCase(this._localPointRepository, this._userSession);

  Future<Stream<List<LocalPoint>>> call() async {

    final int userId = await _requireUserId();

    return _localPointRepository.watchCurrentBatch(userId)
        .map((dtos) => dtos.map((dto) => dto.toDomain()).toList());
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