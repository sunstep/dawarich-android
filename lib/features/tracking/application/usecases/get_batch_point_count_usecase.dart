import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';

final class GetBatchPointCountUseCase {

  final IPointLocalRepository _localPointRepository;

  GetBatchPointCountUseCase(this._localPointRepository);

  Future<int> call(int userId) async {
    return await _localPointRepository.getBatchPointCount(userId);
  }

}