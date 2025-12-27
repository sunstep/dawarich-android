
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';

final class ClearBatchUseCase {

  final IPointLocalRepository _localPointRepository;
  ClearBatchUseCase(this._localPointRepository);

  Future<bool> call() async {
    final int? userId = _userSession.getUserId();

    if (userId == null) {
      return false;
    }

    final result = await _localPointRepository.clearBatch(userId);
    return result > 0;
  }
}