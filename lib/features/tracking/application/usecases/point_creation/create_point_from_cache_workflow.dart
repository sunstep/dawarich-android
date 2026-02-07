

import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/repositories/location_provider_interface.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_usecase.dart';
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class CreatePointFromCacheWorkflow {

  final ILocationProvider _locationProvider;
  final CreatePointUseCase _createPointFromPosition;

  CreatePointFromCacheWorkflow(
      this._locationProvider,
      this._createPointFromPosition
  );

  /// Creates a full point, position data is retrieved from cache.
  Future<Result<LocalPoint, String>> call(int userId) async {

    final DateTime pointCreationTimestamp = DateTime.now().toUtc();
    final Option<LocationFix> posResult =
      await _locationProvider.getLastKnown();

    if (posResult case None()) {
      if (kDebugMode) {
        debugPrint("[DEBUG] No cached position was available");
      }
      return const Err("[DEBUG] NO cached point was available");
    }

    if (kDebugMode) {
      debugPrint("[DEBUG] Cached position found, creating point from it.");
    }

    final LocationFix fix = posResult.unwrap();
    final Result<LocalPoint, String> pointResult =
    await _createPointFromPosition(fix, pointCreationTimestamp, userId);

    if (pointResult case Err(value: String error)) {
      return Err("[DEBUG] Cached point was rejected: $error");
    }

    return pointResult;
  }


}