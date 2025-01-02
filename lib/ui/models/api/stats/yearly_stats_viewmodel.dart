import 'package:dawarich/application/entities/api/stats/yearly_stats.dart';
import 'package:dawarich/ui/models/api/stats/monthly_stats_viewmodel.dart';

class YearlyStatsViewModel {

  int year;
  int totalDistance;
  int totalCountries;
  int totalCities;
  MonthlyStatsViewModel monthlyStats;

  YearlyStatsViewModel(this.year, this.totalDistance, this.totalCountries, this.totalCities, this.monthlyStats);

  factory YearlyStatsViewModel.fromEntity(YearlyStats entity) {
    return YearlyStatsViewModel(
        entity.year,
        entity.totalDistance,
        entity.totalCountries,
        entity.totalCities,
        MonthlyStatsViewModel.fromEntity(entity.monthlyStats));
  }
}