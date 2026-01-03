
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/get_tracker_settings_usecase.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';
import 'package:session_box/session_box.dart';

final class CheckBatchThresholdUseCase {

  final GetTrackerSettingsUseCase _getTrackerSettings;
  final IPointLocalRepository _localPointRepository;
  final SessionBox<User> _userSession;

  CheckBatchThresholdUseCase(this._getTrackerSettings, this._localPointRepository, this._userSession);

  /// A private local point service helper method that checks if the current point batch is due for upload. This method gets called after a point gets stored locally.
  Future<bool> call() async {

    final int userId = await _requireUserId();

    final TrackerSettings settings = await _getTrackerSettings();
    final int currentPoints =
    await _localPointRepository.getBatchPointCount(userId);

    return currentPoints >= settings.pointsPerBatch;
  }

  Future<int> _requireUserId() async {
    final int? userId = _userSession.getUserId();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[ApiPointService] No user session found.');
    }
    return userId;
  }
}