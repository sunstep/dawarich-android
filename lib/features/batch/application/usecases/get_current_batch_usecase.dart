
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:session_box/session_box.dart';

final class GetCurrentBatchUseCase {

  final IPointLocalRepository _localPointRepository;
  final SessionBox<User> _userSession;

  GetCurrentBatchUseCase(this._localPointRepository, this._userSession);

  Future<List<LocalPoint>> call() async {

    final int userId = await _requireUserId();

    List<LocalPoint> batch =
    await _localPointRepository.getCurrentBatch(userId);

    return batch;
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