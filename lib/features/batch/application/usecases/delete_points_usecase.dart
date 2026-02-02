import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';

final class DeletePointsUseCase {

  final IPointLocalRepository _localPointRepository;

  DeletePointsUseCase(this._localPointRepository);

  Future<bool> call(List<int> pointIds, int userId) async {
    final result = await _localPointRepository.deletePoints(userId, pointIds);
    return result > 0;
  }

}