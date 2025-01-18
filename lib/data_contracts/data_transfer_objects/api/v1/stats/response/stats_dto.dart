import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/stats/response/yearly_stats_dto.dart';

class StatsDTO {

  int totalDistance;
  int totalPoints;
  int totalReverseGeocodedPoints;
  int totalCountries;
  int totalCities;
  List<YearlyStatsDTO> yearlyStats;

  StatsDTO({
    required this.totalDistance,
    required this.totalPoints,
    required this.totalReverseGeocodedPoints,
    required this.totalCountries,
    required this.totalCities,
    required this.yearlyStats,
  });

  factory StatsDTO.fromJson(Map<String, dynamic> json) {
    return StatsDTO(
      totalDistance: json["totalDistanceKm"] ?? 0,
      totalPoints: json["totalPointsTracked"] ?? 0,
      totalReverseGeocodedPoints: json["totalReverseGeocodedPoints"] ?? 0,
      totalCountries: json["totalCountriesVisited"] ?? 0,
      totalCities: json["totalCitiesVisited"] ?? 0,
      yearlyStats: (json["yearlyStats"] as List<dynamic>)
          .map((yearStat) => YearlyStatsDTO.fromJson(yearStat))
          .toList(),
    );
  }
}
