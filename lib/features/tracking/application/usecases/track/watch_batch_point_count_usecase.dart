
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:session_box/session_box.dart';

final class WatchBatchPointCountUseCase {

  final IPointLocalRepository _localPointRepository;
  final SessionBox<User> _userSession;

  WatchBatchPointCountUseCase(this._localPointRepository, this._userSession);

  Future<Stream<int>> call() async {
    final int userId = await _requireUserId();

    return _localPointRepository.watchBatchPointCount(userId);
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