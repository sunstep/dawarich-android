import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';

final class ClearBatchUseCase {

  final IPointLocalRepository _localPointRepository;

  ClearBatchUseCase(this._localPointRepository);

  Future<bool> call(int userId) async {
    final batchCount = await _localPointRepository.getBatchPointCount(userId);
    final result = await _localPointRepository.clearBatch(userId);

    return result == batchCount;
  }
}