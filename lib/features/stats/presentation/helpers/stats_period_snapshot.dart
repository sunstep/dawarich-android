import 'package:dawarich/features/stats/presentation/models/stats/monthly_stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats/stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats/yearly_stats_uimodel.dart';

final class StatsPeriodSnapshot {
  final int? selectedYear;
  final int totalDistance;
  final int totalCountries;
  final int totalCities;
  final MonthlyStatsUiModel? monthlyDistance;

  const StatsPeriodSnapshot({
    required this.selectedYear,
    required this.totalDistance,
    required this.totalCountries,
    required this.totalCities,
    required this.monthlyDistance,
  });

  bool get isYearMode => selectedYear != null;
}

StatsPeriodSnapshot resolveStatsForYear({
  required StatsUiModel stats,
  required int? selectedYear,
}) {
  if (selectedYear == null) {
    return StatsPeriodSnapshot(
      selectedYear: null,
      totalDistance: stats.totalDistanceValue,
      totalCountries: stats.totalCountriesValue,
      totalCities: stats.totalCitiesValue,
      monthlyDistance: null,
    );
  }

  final YearlyStatsUiModel? yearModel = _findYear(stats, selectedYear);

  if (yearModel == null) {
    return StatsPeriodSnapshot(
      selectedYear: null,
      totalDistance: stats.totalDistanceValue,
      totalCountries: stats.totalCountriesValue,
      totalCities: stats.totalCitiesValue,
      monthlyDistance: null,
    );
  }

  return StatsPeriodSnapshot(
    selectedYear: selectedYear,
    totalDistance: yearModel.totalDistance,
    totalCountries: yearModel.totalCountries,
    totalCities: yearModel.totalCities,
    monthlyDistance: yearModel.monthlyStats,
  );
}

YearlyStatsUiModel? _findYear(StatsUiModel stats, int year) {
  for (final y in stats.yearlyStats) {
    if (y.year == year) {
      return y;
    }
  }
  return null;
}

List<int> availableYears(StatsUiModel stats) {
  final years = <int>[];
  for (final y in stats.yearlyStats) {
    if (y.year > 0 && years.contains(y.year) == false) {
      years.add(y.year);
    }
  }
  years.sort((a, b) => b.compareTo(a));
  return years;
}