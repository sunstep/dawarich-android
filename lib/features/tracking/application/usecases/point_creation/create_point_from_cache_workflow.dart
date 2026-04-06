

import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/repositories/location_provider_interface.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_usecase.dart';
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class CreatePointFromCacheWorkflow {

  final ILocationProvider _locationProvider;
  final CreatePointUseCase _createPointFromPosition;

  /// Maximum age for a cached position to be considered valid.
  /// Cached positions older than this are rejected as stale.
  static const Duration _maxCacheAge = Duration(seconds: 60);

  CreatePointFromCacheWorkflow(
      this._locationProvider,
      this._createPointFromPosition
  );

  /// Creates a full point, position data is retrieved from cache.
  /// Returns an error if no cached position exists or if it's too old.
  Future<Result<LocalPoint, String>> call(int userId) async {

    final DateTime pointCreationTimestamp = DateTime.now().toUtc();
    final Option<LocationFix> posResult =
      await _locationProvider.getLastKnown();

    if (posResult case None()) {
      if (kDebugMode) {
        debugPrint("[CacheWorkflow] No cached position available");
      }
      return const Err("No cached position available");
    }

    final LocationFix fix = posResult.unwrap();

    // Check if the cached position is too old (stale)
    final Duration age = pointCreationTimestamp.difference(fix.timestampUtc);
    if (age > _maxCacheAge || age < Duration.zero) {
      if (kDebugMode) {
        debugPrint("[CacheWorkflow] Cached position is stale (age: ${age.inSeconds}s, max: ${_maxCacheAge.inSeconds}s)");
      }
      return Err("Cached position is stale (age: ${age.inSeconds}s)");
    }

    if (kDebugMode) {
      debugPrint("[CacheWorkflow] Using cached position (age: ${age.inSeconds}s)");
    }

    final Result<LocalPoint, String> pointResult =
    await _createPointFromPosition(fix, pointCreationTimestamp, userId);

    if (pointResult case Err(value: String error)) {
      return Err("Cached point rejected: $error");
    }

    return pointResult;
  }


}