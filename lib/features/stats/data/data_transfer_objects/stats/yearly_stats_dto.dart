import 'package:dawarich/features/stats/data/data_transfer_objects/stats/monthly_stats_dto.dart';

class YearlyStatsDTO {
  int year;
  int totalDistance;
  int totalCountries;
  int totalCities;
  MonthlyStatsDTO monthlyStats;

  YearlyStatsDTO({
    required this.year,
    required this.totalDistance,
    required this.totalCountries,
    required this.totalCities,
    required this.monthlyStats,
  });

  factory YearlyStatsDTO.fromJson(Map<String, dynamic> json) {
    return YearlyStatsDTO(
      year: json["year"] ?? 0,
      totalDistance: json["totalDistanceKm"] ?? 0,
      totalCountries: json["totalCountriesVisited"] ?? 0,
      totalCities: json["totalCitiesVisited"] ?? 0,
      monthlyStats: MonthlyStatsDTO.fromJson(json["monthlyDistanceKm"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "year": year,
      "totalDistanceKm": totalDistance,
      "totalCountriesVisited": totalCountries,
      "totalCitiesVisited": totalCities,
      "monthlyDistanceKm": monthlyStats.toJson(),
    };
  }
}
