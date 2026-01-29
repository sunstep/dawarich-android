import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/get_tracker_settings_usecase.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';

final class CheckBatchThresholdUseCase {

  final GetTrackerSettingsUseCase _getTrackerSettings;
  final IPointLocalRepository _localPointRepository;

  CheckBatchThresholdUseCase(this._getTrackerSettings, this._localPointRepository);

  /// A private local point service helper method that checks if the current point batch is due for upload. This method gets called after a point gets stored locally.
  Future<bool> call(int userId) async {
    final TrackerSettings settings = await _getTrackerSettings(userId);
    final int currentPoints =
    await _localPointRepository.getBatchPointCount(userId);

    return currentPoints >= settings.pointsPerBatch;
  }
}