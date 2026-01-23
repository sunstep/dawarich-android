import 'package:dawarich/core/application/usecases/api/delete_point_usecase.dart';
import 'package:dawarich/core/application/usecases/api/get_points_usecase.dart';
import 'package:dawarich/core/application/usecases/api/get_total_pages_usecase.dart';
import 'package:dawarich/features/stats/application/repositories/stats_repository_interfaces.dart';
import 'package:dawarich/features/stats/application/usecases/get_stats_usecase.dart';
import 'package:dawarich/features/stats/data/repositories/stats_repository.dart';
import 'package:dawarich/features/timeline/presentation/models/timeline_page_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';
import 'package:dawarich/core/database/repositories/drift/drift_local_point_repository.dart';
import 'package:dawarich/core/database/repositories/drift/drift_track_repository.dart';
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/network/repositories/api_point_repository.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/points/presentation/models/points_page_viewmodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats_page_viewmodel.dart';
import 'package:dawarich/features/batch/application/usecases/watch_current_batch_usecase.dart';
import 'package:dawarich/features/timeline/application/helpers/timeline_points_processor.dart';
import 'package:dawarich/features/timeline/application/usecases/load_timeline_usecase.dart';
import 'session_providers.dart';
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/repositories/i_track_repository.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:dawarich/features/tracking/application/services/point_automation_service.dart';
import 'package:dawarich/features/tracking/application/usecases/get_batch_point_count_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/get_last_point_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/notifications/show_tracker_notification_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_from_cache_workflow.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_from_gps_workflow.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_from_position_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/get_device_model_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/get_tracker_settings_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/save_tracker_settings_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/settings/watch_tracker_settings_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/stream_last_point_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/track/get_active_track_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/track/start_track_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/track/end_track_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/track/watch_batch_point_count_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/system_settings/check_system_settings_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/system_settings/open_system_settings_usecase.dart';
import 'package:dawarich/features/tracking/presentation/models/tracker_page_viewmodel.dart';
import 'package:dawarich/features/tracking/data/repositories/hardware_repository.dart';
import 'package:dawarich/features/tracking/data/repositories/drift_tracker_settings_repository.dart';
import 'package:dawarich/features/batch/application/usecases/point_validator.dart';
import 'package:dawarich/features/timeline/application/usecases/get_default_map_center_usecase.dart';

// --- Repositories ---
final apiPointRepositoryProvider = FutureProvider<IApiPointRepository>((ref) async {
  final dio = await ref.watch(dioClientProvider.future);
  return ApiPointRepository(dio);
});

final pointLocalRepositoryProvider = FutureProvider<IPointLocalRepository>((ref) async {
  final db = await ref.watch(sqliteClientProvider.future);
  return DriftPointLocalRepository(db);
});

final statsRepositoryProvider = FutureProvider<IStatsRepository>((ref) async {
  final dio = await ref.watch(dioClientProvider.future);
  return StatsRepository(dio);
});

// --- Tracking repositories ---
final hardwareRepositoryProvider = Provider<IHardwareRepository>((ref) {
  return HardwareRepository(
    ref.watch(deviceDataClientProvider),
    ref.watch(connectivityDataClientProvider),
  );
});

final trackerSettingsRepositoryProvider = FutureProvider<ITrackerSettingsRepository>((ref) async {
  final db = await ref.watch(sqliteClientProvider.future);
  final hw = ref.watch(hardwareRepositoryProvider);
  return DriftTrackerSettingsRepository(db, hw);
});

final trackRepositoryProvider = FutureProvider<ITrackRepository>((ref) async {
  final db = await ref.watch(sqliteClientProvider.future);
  return DriftTrackRepository(db);
});

// --- Use cases ---
final getPointsUseCaseProvider = FutureProvider<GetPointsUseCase>((ref) async {
  return GetPointsUseCase(await ref.watch(apiPointRepositoryProvider.future));
});

final deletePointUseCaseProvider = FutureProvider<DeletePointUseCase>((ref) async {
  return DeletePointUseCase(await ref.watch(apiPointRepositoryProvider.future));
});

final getTotalPagesUseCaseProvider = FutureProvider<GetTotalPagesUseCase>((ref) async {
  return GetTotalPagesUseCase(await ref.watch(apiPointRepositoryProvider.future));
});

final getStatsUseCaseProvider = FutureProvider<GetStatsUseCase>((ref) async {
  return GetStatsUseCase(await ref.watch(statsRepositoryProvider.future));
});

// --- Tracking usecases ---
final getTrackerSettingsUseCaseProvider = FutureProvider<GetTrackerSettingsUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final repo = await ref.watch(trackerSettingsRepositoryProvider.future);
  return GetTrackerSettingsUseCase(repo, session);
});

final watchTrackerSettingsUseCaseProvider = FutureProvider<WatchTrackerSettingsUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final repo = await ref.watch(trackerSettingsRepositoryProvider.future);
  return WatchTrackerSettingsUseCase(repo, session);
});

final showTrackerNotificationUseCaseProvider = Provider<ShowTrackerNotificationUseCase>((ref) {
  return ShowTrackerNotificationUseCase();
});

final getBatchPointCountUseCaseProvider = FutureProvider<GetBatchPointCountUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final repo = await ref.watch(pointLocalRepositoryProvider.future);
  return GetBatchPointCountUseCase(repo, session);
});

final getLastPointUseCaseProvider = FutureProvider<GetLastPointUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final repo = await ref.watch(pointLocalRepositoryProvider.future);
  return GetLastPointUseCase(repo, session);
});

final pointValidatorProvider = FutureProvider<PointValidator>((ref) async {
  final getSettings = await ref.watch(getTrackerSettingsUseCaseProvider.future);
  return PointValidator(getSettings);
});

final createPointFromPositionUseCaseProvider = FutureProvider<CreatePointFromPositionUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final validator = await ref.watch(pointValidatorProvider.future);
  return CreatePointFromPositionUseCase(
    ref.watch(hardwareRepositoryProvider),
    await ref.watch(pointLocalRepositoryProvider.future),
    await ref.watch(trackRepositoryProvider.future),
    validator,
    session,
  );
});

final createPointFromGpsWorkflowProvider = FutureProvider<CreatePointFromGpsWorkflow>((ref) async {
  final prefs = await ref.watch(getTrackerSettingsUseCaseProvider.future);
  final createFromPos = await ref.watch(createPointFromPositionUseCaseProvider.future);
  return CreatePointFromGpsWorkflow(prefs, ref.watch(hardwareRepositoryProvider), createFromPos);
});

final createPointFromCacheWorkflowProvider = FutureProvider<CreatePointFromCacheWorkflow>((ref) async {
  final createFromPos = await ref.watch(createPointFromPositionUseCaseProvider.future);
  return CreatePointFromCacheWorkflow(ref.watch(hardwareRepositoryProvider), createFromPos);
});

final pointAutomationServiceProvider = FutureProvider<PointAutomationService>((ref) async {
  final watchSettings = await ref.watch(watchTrackerSettingsUseCaseProvider.future);
  final createGps = await ref.watch(createPointFromGpsWorkflowProvider.future);
  final createCache = await ref.watch(createPointFromCacheWorkflowProvider.future);
  final batchCount = await ref.watch(getBatchPointCountUseCaseProvider.future);
  final showNotif = ref.watch(showTrackerNotificationUseCaseProvider);

  return PointAutomationService(
    watchSettings,
    createGps,
    createCache,
    batchCount,
    showNotif,
  );
});

// --- Timeline helpers / use cases ---
final timelinePointsProcessorProvider = Provider<TimelinePointsProcessor>((ref) {
  return TimelinePointsProcessor();
});

final getDefaultMapCenterUseCaseProvider = Provider<GetDefaultMapCenterUseCase>((ref) {
  return GetDefaultMapCenterUseCase();
});

final loadTimelineUseCaseProvider = FutureProvider<LoadTimelineUseCase>((ref) async {
  return LoadTimelineUseCase(
    await ref.watch(apiPointRepositoryProvider.future),
    ref.watch(timelinePointsProcessorProvider),
  );
});

final watchCurrentBatchUseCaseProvider = FutureProvider<WatchCurrentBatchUseCase>((ref) async {
  final localRepo = await ref.watch(pointLocalRepositoryProvider.future);
  final session = await ref.watch(sessionBoxProvider.future);
  return WatchCurrentBatchUseCase(localRepo, session);
});

// --- ViewModels ---
final timelineViewModelProvider = FutureProvider<TimelineViewModel>((ref) async {
  final vm = TimelineViewModel(
    await ref.watch(loadTimelineUseCaseProvider.future),
    ref.watch(timelinePointsProcessorProvider),
    ref.watch(getDefaultMapCenterUseCaseProvider),
    await ref.watch(watchCurrentBatchUseCaseProvider.future),
  );

  // Kick off initial load.
  await vm.initialize();
  ref.onDispose(vm.dispose);
  return vm;
});

final statsPageViewModelProvider = FutureProvider<StatsPageViewModel>((ref) async {
  return StatsPageViewModel(await ref.watch(getStatsUseCaseProvider.future));
});

final pointsPageViewModelProvider = FutureProvider<PointsPageViewModel>((ref) async {
  return PointsPageViewModel(
    await ref.watch(getPointsUseCaseProvider.future),
    await ref.watch(deletePointUseCaseProvider.future),
    await ref.watch(getTotalPagesUseCaseProvider.future),
  );
});

final getDeviceModelUseCaseProvider = Provider<GetDeviceModelUseCase>((ref) {
  return GetDeviceModelUseCase(ref.watch(hardwareRepositoryProvider));
});

final saveTrackerSettingsUseCaseProvider = FutureProvider<SaveTrackerSettingsUseCase>((ref) async {
  return SaveTrackerSettingsUseCase(await ref.watch(trackerSettingsRepositoryProvider.future));
});

final streamLastPointUseCaseProvider = FutureProvider<StreamLastPointUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final repo = await ref.watch(pointLocalRepositoryProvider.future);
  return StreamLastPointUseCase(repo, session);
});

final streamBatchPointCountUseCaseProvider = FutureProvider<StreamBatchPointCountUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final repo = await ref.watch(pointLocalRepositoryProvider.future);
  return StreamBatchPointCountUseCase(repo, session);
});

final startTrackUseCaseProvider = FutureProvider<StartTrackUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final repo = await ref.watch(trackRepositoryProvider.future);
  return StartTrackUseCase(repo, session);
});

final endTrackUseCaseProvider = FutureProvider<EndTrackUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final repo = await ref.watch(trackRepositoryProvider.future);
  return EndTrackUseCase(repo, session);
});

final getActiveTrackUseCaseProvider = FutureProvider<GetActiveTrackUseCase>((ref) async {
  final session = await ref.watch(sessionBoxProvider.future);
  final repo = await ref.watch(trackRepositoryProvider.future);
  return GetActiveTrackUseCase(repo, session);
});

final checkSystemSettingsUseCaseProvider = Provider<CheckSystemSettingsUseCase>((ref) {
  return CheckSystemSettingsUseCase();
});

final openSystemSettingsUseCaseProvider = Provider<OpenSystemSettingsUseCase>((ref) {
  return OpenSystemSettingsUseCase();
});

final trackerPageViewModelProvider = FutureProvider<TrackerPageViewModel>((ref) async {
  final vm = TrackerPageViewModel(
    await ref.watch(getTrackerSettingsUseCaseProvider.future),
    await ref.watch(saveTrackerSettingsUseCaseProvider.future),
    ref.watch(getDeviceModelUseCaseProvider),
    await ref.watch(streamLastPointUseCaseProvider.future),
    await ref.watch(streamBatchPointCountUseCaseProvider.future),
    await ref.watch(createPointFromGpsWorkflowProvider.future),
    await ref.watch(startTrackUseCaseProvider.future),
    await ref.watch(endTrackUseCaseProvider.future),
    await ref.watch(getActiveTrackUseCaseProvider.future),
    ref.watch(checkSystemSettingsUseCaseProvider),
    ref.watch(openSystemSettingsUseCaseProvider),
  );

  await vm.initialize();
  ref.onDispose(vm.dispose);
  return vm;
});
