
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';

final class SaveTrackerSettingsUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  SaveTrackerSettingsUseCase(this._trackerSettingsRepository);



  Future<void> call(TrackerSettings settings) async {

    await _trackerSettingsRepository.set(settings: settings);
  }


}