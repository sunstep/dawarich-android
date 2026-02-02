import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';

final class StreamBatchPointCountUseCase {

  final IPointLocalRepository _localPointRepository;

  StreamBatchPointCountUseCase(this._localPointRepository);

  Stream<int> call(int userId) {
    return _localPointRepository.watchBatchPointCount(userId);
  }

}