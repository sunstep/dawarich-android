import 'package:dawarich/features/stats/presentation/models/stats/monthly_stats_uimodel.dart';

class YearlyStatsUiModel {
  int year;
  int totalDistance;
  int totalCountries;
  int totalCities;
  MonthlyStatsUiModel monthlyStats;

  YearlyStatsUiModel({required this.year,
    required this.totalDistance,
    required this.totalCountries,
    required this.totalCities,
    required this.monthlyStats
  });

}
