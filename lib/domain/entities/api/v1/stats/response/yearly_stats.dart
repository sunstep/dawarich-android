import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/stats/response/yearly_stats_dto.dart';
import 'package:dawarich/domain/entities/api/v1/stats/response/monthly_stats.dart';

class YearlyStats {
  int year;
  int totalDistance;
  int totalCountries;
  int totalCities;
  MonthlyStats monthlyStats;

  YearlyStats(this.year, this.totalDistance, this.totalCountries, this.totalCities, this.monthlyStats);

  factory YearlyStats.fromDTO(YearlyStatsDTO dto) {
    return YearlyStats(
        dto.year,
        dto.totalDistance,
        dto.totalCountries,
        dto.totalCities,
        MonthlyStats.fromDTO(dto.monthlyStats));
  }
}