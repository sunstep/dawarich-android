import 'dart:async';

import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/features/stats/application/usecases/get_stats_usecase.dart';
import 'package:dawarich/features/stats/domain/stats/stats.dart';
import 'package:dawarich/features/stats/presentation/converters/stats_page_model_converter.dart';
import 'package:dawarich/features/stats/presentation/models/stats/stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/viewmodels/stats_page_state.dart';
import 'package:option_result/option.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_viewmodel.g.dart';

/// AsyncNotifier that manages stats page state
@Riverpod()
class StatsViewmodel extends _$StatsViewmodel {

  @override
  FutureOr<StatsPageState?> build() async {

    final getStats = await ref.watch(getStatsUseCaseProvider.future);
    final getLastSyncedAt = await ref.watch(getLastStatsSyncUseCaseProvider.future);

    final (statsOpt, lastSyncedAtUtc) = await (
    getStats(),
    getLastSyncedAt(),
    ).wait;

    if (statsOpt case Some(value: final stats)) {
      return StatsPageState(
        stats: stats.toUiModel(),
        syncedAtUtc: lastSyncedAtUtc,
      );
    }

    return StatsPageState(
      stats: null,
      syncedAtUtc: lastSyncedAtUtc,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final getStats = await ref.read(getStatsUseCaseProvider.future);
      final getLastSyncedAt = await ref.read(getLastStatsSyncUseCaseProvider.future);

      final StatsUiModel? stats = await _fetchStats(
        getStats,
        forceRefresh: true,
      );

      final DateTime? lastSyncedAtUtc = await getLastSyncedAt();

      return StatsPageState(
        stats: stats,
        syncedAtUtc: lastSyncedAtUtc,
      );
    });
  }

  Future<StatsUiModel?> _fetchStats(
      GetStatsUseCase useCase, {
        bool forceRefresh = false,
      }) async {
    final Option<Stats> result = await useCase(forceRefresh: forceRefresh);

    if (result case Some(value: final Stats stats)) {
      return stats.toUiModel();
    }

    return null;
  }

}