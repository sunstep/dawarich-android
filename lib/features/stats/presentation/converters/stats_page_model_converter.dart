

import 'package:dawarich/features/stats/domain/stats.dart';
import 'package:dawarich/features/stats/presentation/converters/yearly_stats_converter.dart';
import 'package:dawarich/features/stats/presentation/models/stats_viewmodel.dart';

extension StatsPageDomainToViewModelConverter on Stats {
  StatsViewModel toViewModel() {
    return StatsViewModel(
      totalDistance,
      totalPoints,
      totalReverseGeocodedPoints,
      totalCountries,
      totalCities,
      yearlyStats.map((yearlyStats) => yearlyStats.toViewModel()).toList(),
    );
  }
}

extension StatsPageViewModelToDomainConverter on StatsViewModel {
  Stats toDomain() {
    return Stats(
      totalDistance: totalDistanceValue,
      totalPoints: totalPointsValue,
      totalReverseGeocodedPoints: totalReverseGeocodedPointsValue,
      totalCountries: totalCountriesValue,
      totalCities: totalCitiesValue,
      yearlyStats: yearlyStats.map((yearlyStats) => yearlyStats.toDomain()).toList(),
    );
  }
}
