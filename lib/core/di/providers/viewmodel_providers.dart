import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/features/points/presentation/models/points_page_viewmodel.dart';
import 'package:dawarich/features/timeline/presentation/models/timeline_page_viewmodel.dart';
import 'package:dawarich/features/tracking/presentation/models/tracker_page_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timelineViewModelProvider = FutureProvider<TimelineViewModel>((ref) async {
  final vm = TimelineViewModel(
    await ref.watch(loadTimelineUseCaseProvider.future),
    ref.watch(timelinePointsProcessorProvider),
    ref.watch(getDefaultMapCenterUseCaseProvider),
    await ref.watch(watchCurrentBatchUseCaseProvider.future),
  );

  await vm.initialize();
  ref.onDispose(vm.dispose);
  return vm;
});

// statsPageNotifierProvider is now defined in stats_page_viewmodel.dart

final pointsPageViewModelProvider = FutureProvider<PointsPageViewModel>((ref) async {
  return PointsPageViewModel(
    await ref.watch(getPointsUseCaseProvider.future),
    await ref.watch(deletePointUseCaseProvider.future),
    await ref.watch(getTotalPagesUseCaseProvider.future),
  );
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
