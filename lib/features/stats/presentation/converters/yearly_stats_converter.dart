

import 'package:dawarich/features/stats/domain/yearly_stats.dart';
import 'package:dawarich/features/stats/presentation/converters/monthly_stats_converter.dart';
import 'package:dawarich/features/stats/presentation/models/yearly_stats_uimodel.dart';

extension YearlyStatsToViewModelConverter on YearlyStats {
  YearlyStatsUiModel toUiModel() {
    return YearlyStatsUiModel(
      year: year,
      totalDistance: totalDistance,
      totalCountries: totalCountries,
      totalCities: totalCities,
      monthlyStats: monthlyStats.toUiModel()
    );
  }
}

extension YearlyStatsToDomainConverter on YearlyStatsUiModel {
  YearlyStats toDomain() {
    return YearlyStats(
      year: year,
      totalDistance: totalDistance,
      totalCountries: totalCountries,
      totalCities: totalCities,
      monthlyStats: monthlyStats.toDomain()
    );
  }
}