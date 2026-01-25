import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:option_result/option.dart';

final class StreamLastPointUseCase {

  final IPointLocalRepository _localPointRepository;

  StreamLastPointUseCase(this._localPointRepository);

  Stream<Option<LastPoint>> call(int userId) {
    return _localPointRepository.watchLastPoint(userId);
  }

}