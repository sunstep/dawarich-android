import 'package:dawarich/domain/entities/api/v1/stats/response/stats.dart';
import 'package:dawarich/features/stats/presentation/models/yearly_stats_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

final class StatsViewModel {
  final int _totalDistance;
  final int _totalPoints;
  final int _totalReverseGeocodedPoints;
  final int _totalCountries;
  final int _totalCities;
  List<YearlyStatsViewModel> yearlyStats;

  StatsViewModel(
      this._totalDistance,
      this._totalPoints,
      this._totalReverseGeocodedPoints,
      this._totalCountries,
      this._totalCities,
      this.yearlyStats);

  factory StatsViewModel.fromDomain(Stats entity) {
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

  String _format(int number, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.decimalPattern(locale).format(number);
  }

  String totalDistance(BuildContext context) =>
      _format(_totalDistance, context);
  String totalPoints(BuildContext context) => _format(_totalPoints, context);
  String totalReverseGeocodedPoints(BuildContext context) =>
      _format(_totalReverseGeocodedPoints, context);
  String totalCountries(BuildContext context) =>
      _format(_totalCountries, context);
  String totalCities(BuildContext context) => _format(_totalCities, context);
}
