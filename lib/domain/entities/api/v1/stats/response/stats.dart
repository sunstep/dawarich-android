import 'package:dawarich/domain/entities/api/v1/stats/response/yearly_stats.dart';
import 'package:dawarich/interfaces/data_transfer_objects/api/v1/stats/response/stats_dto.dart';

class Stats {
  int totalDistance;
  int totalPoints;
  int totalReverseGeocodedPoints;
  int totalCountries;
  int totalCities;
  List<YearlyStats> yearlyStats;
  
  Stats(this.totalDistance, this.totalPoints, this.totalReverseGeocodedPoints, this.totalCountries, this.totalCities, this.yearlyStats);
  
  factory Stats.fromDTO(StatsDTO dto) {
    
    return Stats(
      dto.totalDistance,
      dto.totalPoints,
      dto.totalReverseGeocodedPoints,
      dto.totalCountries,
      dto.totalCities,
      dto.yearlyStats
          .map((yearlyStatsDTO) => YearlyStats.fromDTO(yearlyStatsDTO))
          .toList(),);
  }
}