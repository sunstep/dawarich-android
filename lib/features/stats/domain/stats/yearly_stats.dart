import 'package:dawarich/features/stats/data/data_transfer_objects/stats/yearly_stats_dto.dart';
import 'package:dawarich/features/stats/domain/stats/monthly_stats.dart';

class YearlyStats {
  int year;
  int totalDistance;
  int totalCountries;
  int totalCities;
  MonthlyStats monthlyStats;

  YearlyStats({required this.year,
    required this.totalDistance,
    required this.totalCountries,
    required this.totalCities,
    required this.monthlyStats
  });

  factory YearlyStats.fromDTO(YearlyStatsDTO dto) {
    return YearlyStats(year: dto.year, totalDistance:  dto.totalDistance, totalCountries:  dto.totalCountries,
        totalCities:  dto.totalCities, monthlyStats:  MonthlyStats.fromDTO(dto.monthlyStats));
  }
}
