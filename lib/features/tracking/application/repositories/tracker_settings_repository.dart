import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';

abstract interface class ITrackerSettingsRepository {

  Future<TrackerSettings> get({required int userId});
  Future<void> set({required TrackerSettings settings});

  Stream<TrackerSettings> watch({required int userId});
}
