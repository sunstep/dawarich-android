import 'package:dawarich/domain/entities/api/v1/stats/response/yearly_stats.dart';
import 'package:dawarich/features/stats/presentation/models/monthly_stats_viewmodel.dart';

class YearlyStatsViewModel {
  int year;
  int totalDistance;
  int totalCountries;
  int totalCities;
  MonthlyStatsViewModel monthlyStats;

  YearlyStatsViewModel(this.year, this.totalDistance, this.totalCountries,
      this.totalCities, this.monthlyStats);

  factory YearlyStatsViewModel.fromEntity(YearlyStats entity) {
    return YearlyStatsViewModel(
        entity.year,
        entity.totalDistance,
        entity.totalCountries,
        entity.totalCities,
        MonthlyStatsViewModel.fromEntity(entity.monthlyStats));
  }
}
