
import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/result.dart';

final class StorePointUseCase {

  final IPointLocalRepository _localPointRepository;

  StorePointUseCase(this._localPointRepository);

  Future<Result<LocalPoint, String>> call(LocalPoint point) async {
    final int storeResult = await _localPointRepository.storePoint(point);

    if (storeResult <= 0) {
      return Err("Failed to store point");
    }

    // Clean up: delete any old uploaded reference points now that we have a new one
    // This keeps storage clean while maintaining the ability to validate against the last point
    try {
      final deleted = await _localPointRepository.deleteUploadedPointsExceptLast(point.userId);
      if (kDebugMode && deleted > 0) {
        debugPrint("[StorePoint] Cleaned up $deleted old reference point(s)");
      }
    } catch (e) {
      // Non-critical, just log
      if (kDebugMode) {
        debugPrint("[StorePoint] Cleanup failed: $e");
      }
    }

    return Ok(point);
  }
}