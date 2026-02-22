import 'package:dawarich/features/stats/presentation/models/stats/monthly_stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/providers/stats_data_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_time_monthly_distance_provider.g.dart';

@riverpod
MonthlyStatsUiModel? allTimeMonthlyDistance(Ref ref) {
  final statsAsync = ref.watch(statsDataProvider);

  return statsAsync.maybeWhen(
    data: (stats) {
      if (stats == null) {
        return null;
      }

      final months = stats.yearlyStats.map((y) => y.monthlyStats);
      return MonthlyStatsUiModel.sum(months);
    },
    orElse: () => null,
  );
}