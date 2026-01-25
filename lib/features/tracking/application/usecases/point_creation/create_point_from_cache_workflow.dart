

import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_from_position_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

final class CreatePointFromCacheWorkflow {

  final IHardwareRepository _hardwareInterfaces;
  final CreatePointFromPositionUseCase _createPointFromPosition;

  CreatePointFromCacheWorkflow(
      this._hardwareInterfaces,
      this._createPointFromPosition
  );

  /// Creates a full point, position data is retrieved from cache.
  Future<Result<LocalPoint, String>> call(int userId) async {

    final DateTime pointCreationTimestamp = DateTime.now().toUtc();
    final Option<Position> posResult =
    await _hardwareInterfaces.getCachedPosition();

    if (posResult case None()) {
      if (kDebugMode) {
        debugPrint("[DEBUG] No cached position was available");
      }
      return const Err("[DEBUG] NO cached point was available");
    }

    if (kDebugMode) {
      debugPrint("[DEBUG] Cached position found, creating point from it.");
    }

    final Position position = posResult.unwrap();
    final Result<LocalPoint, String> pointResult =
    await _createPointFromPosition(position, pointCreationTimestamp, userId);

    if (pointResult case Err(value: String error)) {
      return Err("[DEBUG] Cached point was rejected: $error");
    }

    return pointResult;
  }


}