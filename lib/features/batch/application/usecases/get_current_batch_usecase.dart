import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';

final class GetCurrentBatchUseCase {

  final IPointLocalRepository _localPointRepository;

  GetCurrentBatchUseCase(this._localPointRepository);

  Future<List<LocalPoint>> call(int userId) async {
    return await _localPointRepository.getCurrentBatch(userId);
  }

}