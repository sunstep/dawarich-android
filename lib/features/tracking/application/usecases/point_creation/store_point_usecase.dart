
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:option_result/result.dart';

final class StorePointUseCase {

  final IPointLocalRepository _localPointRepository;

  StorePointUseCase(this._localPointRepository);

  Future<Result<LocalPoint, String>> call(LocalPoint point) async {
    final int storeResult = await _localPointRepository.storePoint(point);

    return storeResult > 0
        ? Ok(point)
        : Err("Failed to store point");
  }
}