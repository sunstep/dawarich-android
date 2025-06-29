import 'package:dawarich/features/stats/data_contracts/data_transfer_objects/yearly_stats_dto.dart';
import 'package:dawarich/features/stats/domain/monthly_stats.dart';

class YearlyStats {
  int year;
  int totalDistance;
  int totalCountries;
  int totalCities;
  MonthlyStats monthlyStats;

  YearlyStats(this.year, this.totalDistance, this.totalCountries,
      this.totalCities, this.monthlyStats);

  factory YearlyStats.fromDTO(YearlyStatsDTO dto) {
    return YearlyStats(dto.year, dto.totalDistance, dto.totalCountries,
        dto.totalCities, MonthlyStats.fromDTO(dto.monthlyStats));
  }
}
