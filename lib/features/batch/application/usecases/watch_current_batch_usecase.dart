import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';

final class WatchCurrentBatchUseCase {

  final IPointLocalRepository _localPointRepository;

  WatchCurrentBatchUseCase(this._localPointRepository);

  Stream<List<LocalPoint>> call(int userId) {
    return _localPointRepository.watchCurrentBatch(userId);
  }
}