import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/features/stats/application/queries/countries_query.dart';
import 'package:dawarich/features/stats/application/usecases/get_stats_usecase.dart';
import 'package:dawarich/features/stats/domain/stats/stats.dart';
import 'package:dawarich/features/stats/presentation/converters/stats_page_model_converter.dart';
import 'package:dawarich/features/stats/presentation/models/stats/stats_uimodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:option_result/option.dart';

/// Provider for the stats page notifier
final statsViewmodelProvider = AsyncNotifierProvider<StatsViewmodel, StatsUiModel?>(
  StatsViewmodel.new,
);

/// AsyncNotifier that manages stats page state
final class StatsViewmodel extends AsyncNotifier<StatsUiModel?> {

  CountriesQuery? _lastQuery;

  @override
  Future<StatsUiModel?> build() async {

    final query = CountriesQuery(
      startAt: DateTime.utc(1970, 1, 1),
      endAt: DateTime.now().toUtc(),
    );

    _lastQuery = query;

    final useCase = await ref.watch(getStatsUseCaseProvider.future);
    return _fetchStats(useCase);
  }

  Future<StatsUiModel?> _fetchStats(GetStatsUseCase useCase) async {
    try {
      final Option<Stats> result = await useCase();

      if (result case Some(value: final Stats stats)) {
        return stats.toUiModel();
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
