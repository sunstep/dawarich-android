import 'package:dawarich/application/entities/api/stats/response/stats.dart';
import 'package:dawarich/ui/models/api/stats/response/yearly_stats_viewmodel.dart';

class StatsViewModel{

  int totalDistance;
  int totalPoints;
  int totalReverseGeocodedPoints;
  int totalCountries;
  int totalCities;
  List<YearlyStatsViewModel> yearlyStats;


  StatsViewModel(this.totalDistance, this.totalPoints, this.totalReverseGeocodedPoints, this.totalCountries, this.totalCities, this.yearlyStats);

  factory StatsViewModel.fromEntity(Stats entity) {

    return StatsViewModel(
      entity.totalDistance,
      entity.totalPoints,
      entity.totalReverseGeocodedPoints,
      entity.totalCountries,
      entity.totalCities,
      entity.yearlyStats
          .map((yearlyStats) => YearlyStatsViewModel.fromEntity(yearlyStats))
          .toList(),
    );
  }


}