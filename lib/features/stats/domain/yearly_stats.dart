import 'package:dawarich/features/stats/data_contracts/data_transfer_objects/yearly_stats_dto.dart';
import 'package:dawarich/features/stats/domain/monthly_stats.dart';

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
