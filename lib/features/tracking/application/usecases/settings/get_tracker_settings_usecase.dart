

import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';

final class GetTrackerSettingsUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;

  GetTrackerSettingsUseCase(this._trackerSettingsRepository);

  Future<TrackerSettings> call(int userId) async {
    final settings = await _trackerSettingsRepository.get(userId: userId);
    return settings;
  }

}