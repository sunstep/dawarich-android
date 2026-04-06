import 'package:dawarich/features/stats/presentation/models/stats/monthly_stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats/yearly_stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/providers/stats_data_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_period_provider.g.dart';

@riverpod
class SelectedStatsYear extends _$SelectedStatsYear {
  @override
  int? build() => null;

  void setYear(int? year) {
    state = year;
  }

  void clear() {
    state = null;
  }
}

/// Derived: which years exist in the API response.
@riverpod
List<int> availableStatsYears(Ref ref) {
  final statsAsync = ref.watch(statsDataProvider);

  return statsAsync.maybeWhen(
    data: (stats) {
      final years = stats?.yearlyStats.map((y) => y.year).toList() ?? <int>[];
      years.sort();
      return years;
    },
    orElse: () => const <int>[],
  );
}

/// Derived: pick a default year when none is selected.
/// - Prefer the latest year available.
@riverpod
int? effectiveStatsYear(Ref ref) {
  final selected = ref.watch(selectedStatsYearProvider);
  if (selected != null) {
    return selected;
  }

  final years = ref.watch(availableStatsYearsProvider);
  if (years.isEmpty) {
    return null;
  }

  return years.last;
}

/// Derived: the YearlyStats for the selected/effective year.
@riverpod
YearlyStatsUiModel? selectedYearStats(Ref ref) {
  final statsAsync = ref.watch(statsDataProvider);
  final year = ref.watch(effectiveStatsYearProvider);

  return statsAsync.maybeWhen(
    data: (stats) {
      final list = stats?.yearlyStats ?? const <YearlyStatsUiModel>[];
      if (year == null) {
        return null;
      }
      for (final item in list) {
        if (item.year == year) {
          return item;
        }
      }
      return null;
    },
    orElse: () => null,
  );
}

/// Derived: monthly distance numbers for the selected year.
/// (You said: “only allow year selection and then show monthly distance”.)
@riverpod
MonthlyStatsUiModel? selectedYearMonthlyDistance(Ref ref) {
  return ref.watch(selectedYearStatsProvider)?.monthlyStats;
}