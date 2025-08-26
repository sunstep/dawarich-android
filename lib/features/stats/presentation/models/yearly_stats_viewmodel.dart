import 'package:dawarich/features/stats/domain/yearly_stats.dart';
import 'package:dawarich/features/stats/presentation/models/monthly_stats_viewmodel.dart';

class YearlyStatsViewModel {
  int year;
  int totalDistance;
  int totalCountries;
  int totalCities;
  MonthlyStatsViewModel monthlyStats;

  YearlyStatsViewModel({required this.year,
    required this.totalDistance,
    required this.totalCountries,
    required this.totalCities,
    required this.monthlyStats
  });
  factory YearlyStatsViewModel.fromDomain(YearlyStats entity) {
    return YearlyStatsViewModel(
        year: entity.year,
        totalDistance: entity.totalDistance,
        totalCountries: entity.totalCountries,
        totalCities: entity.totalCities,
        monthlyStats: MonthlyStatsViewModel.fromDomain(entity.monthlyStats));
  }
}
