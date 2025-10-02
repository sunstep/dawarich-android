

import 'package:dawarich/features/stats/domain/yearly_stats.dart';
import 'package:dawarich/features/stats/presentation/converters/monthly_stats_converter.dart';
import 'package:dawarich/features/stats/presentation/models/yearly_stats_viewmodel.dart';

extension YearlyStatsToViewModelConverter on YearlyStats {
  YearlyStatsViewModel toViewModel() {
    return YearlyStatsViewModel(
      year: year,
      totalDistance: totalDistance,
      totalCountries: totalCountries,
      totalCities: totalCities,
      monthlyStats: monthlyStats.toViewModel()
    );
  }
}

extension YearlyStatsToDomainConverter on YearlyStatsViewModel {
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