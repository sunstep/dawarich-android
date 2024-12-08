import 'package:dawarich/application/entities/monthly_stats.dart';
import 'package:dawarich/domain/data_transfer_objects/yearly_stats_dto.dart';

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