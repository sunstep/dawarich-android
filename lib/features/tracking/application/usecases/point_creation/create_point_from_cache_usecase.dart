

import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

final class CreatePointFromCacheUseCase {

  final IHardwareRepository _hardwareInterfaces;

  CreatePointFromCacheUseCase(this._hardwareInterfaces);

  /// Creates a full point, position data is retrieved from cache.
  Future<Result<LocalPoint, String>> call() async {

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
    await createPointFromPosition(position, pointCreationTimestamp);

    if (pointResult case Err(value: String error)) {
      return Err("[DEBUG] Cached point was rejected: $error");
    }

    await autoStoreAndUpload(pointResult.unwrap());
    return pointResult;
  }


}