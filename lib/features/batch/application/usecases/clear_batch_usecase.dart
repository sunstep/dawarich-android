
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:session_box/session_box.dart';

final class ClearBatchUseCase {

  final IPointLocalRepository _localPointRepository;
  final SessionBox<User> _userSession;
  ClearBatchUseCase(this._localPointRepository, this._userSession);

  Future<bool> call() async {

    final int userId = await _requireUserId();

    final batchCount = await _localPointRepository.getBatchPointCount(userId);
    final result = await _localPointRepository.clearBatch(userId);

    return result == batchCount;
  }

  Future<int> _requireUserId() async {
    final int? userId = _userSession.getUserId();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[ApiPointService] No user session found.');
    }
    return userId;
  }
}