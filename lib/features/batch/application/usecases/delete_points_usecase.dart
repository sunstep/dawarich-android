
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:session_box/session_box.dart';

final class DeletePointsUseCase {

  final IPointLocalRepository _localPointRepository;
  final SessionBox<User> _userSession;
  DeletePointsUseCase(this._localPointRepository, this._userSession);

  Future<bool> call(List<int> pointIds) async {
    final int userId = await _requireUserId();

    final result = await _localPointRepository.deletePoints(userId, pointIds);

    return result > 0;
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