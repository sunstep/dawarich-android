import 'package:dawarich/features/stats/domain/yearly_stats.dart';
import 'package:dawarich/features/stats/data/data_transfer_objects/stats_dto.dart';

class Stats {
  int totalDistance;
  int totalPoints;
  int totalReverseGeocodedPoints;
  int totalCountries;
  int totalCities;
  List<YearlyStats> yearlyStats;

  Stats({
    required this.totalDistance,
    required this.totalPoints,
    required this.totalReverseGeocodedPoints,
    required this.totalCountries,
    required this.totalCities,
    required this.yearlyStats
  });

  factory Stats.fromDTO(StatsDTO dto) {
    return Stats(
      totalDistance: dto.totalDistance,
      totalPoints: dto.totalPoints,
      totalReverseGeocodedPoints: dto.totalReverseGeocodedPoints,
      totalCountries: dto.totalCountries,
      totalCities: dto.totalCities,
      yearlyStats: dto.yearlyStats
          .map((yearlyStatsDTO) => YearlyStats.fromDTO(yearlyStatsDTO))
          .toList(),
    );
  }
}
