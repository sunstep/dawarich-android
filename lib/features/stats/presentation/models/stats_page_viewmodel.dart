import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/features/stats/application/usecases/get_stats_usecase.dart';
import 'package:dawarich/features/stats/domain/stats.dart';
import 'package:dawarich/features/stats/presentation/converters/stats_page_model_converter.dart';
import 'package:dawarich/features/stats/presentation/models/stats_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:option_result/option.dart';

/// Provider for the stats page notifier
final statsPageNotifierProvider = AsyncNotifierProvider<StatsPageNotifier, StatsViewModel?>(
  StatsPageNotifier.new,
);

/// AsyncNotifier that manages stats page state
final class StatsPageNotifier extends AsyncNotifier<StatsViewModel?> {
  @override
  Future<StatsViewModel?> build() async {
    final useCase = await ref.watch(getStatsUseCaseProvider.future);
    return _fetchStats(useCase);
  }

  Future<StatsViewModel?> _fetchStats(GetStatsUseCase useCase) async {
    try {
      final Option<Stats> result = await useCase();

      if (result case Some(value: final Stats stats)) {
        return stats.toViewModel();
      }

      return null;
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[StatsPageNotifier] fetchStats failed: $e\n$s');
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = await ref.read(getStatsUseCaseProvider.future);
      return _fetchStats(useCase);
    });
  }
}
