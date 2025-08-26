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

  int get totalDistanceValue => _totalDistance;
  int get totalPointsValue => _totalPoints;
  int get totalReverseGeocodedPointsValue => _totalReverseGeocodedPoints;
  int get totalCountriesValue => _totalCountries;
  int get totalCitiesValue => _totalCities;

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
