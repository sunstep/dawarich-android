
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:session_box/session_box.dart';

final class GetBatchPointCountUseCase {

  final IPointLocalRepository _localPointRepository;
  final SessionBox<User> _userSession;

  GetBatchPointCountUseCase(this._localPointRepository, this._userSession);

  Future<int> call() async {
    final int userId = await _requireUserId();

    int result =
    await _localPointRepository.getBatchPointCount(userId);


    return result;
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