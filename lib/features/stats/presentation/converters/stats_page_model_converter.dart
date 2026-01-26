

import 'package:dawarich/features/stats/domain/stats.dart';
import 'package:dawarich/features/stats/presentation/converters/yearly_stats_converter.dart';
import 'package:dawarich/features/stats/presentation/models/stats_uimodel.dart';

extension StatsPageDomainToViewModelConverter on Stats {
  StatsUiModel toUiModel() {
    return StatsUiModel(
      totalDistance,
      totalPoints,
      totalReverseGeocodedPoints,
      totalCountries,
      totalCities,
      yearlyStats.map((yearlyStats) => yearlyStats.toUiModel()).toList(),
    );
  }
}

extension StatsPageViewModelToDomainConverter on StatsUiModel {
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
