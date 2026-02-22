import 'package:dawarich/features/stats/presentation/models/countries/visited_city_flat_uimodel.dart' show VisitedCityFlatUiModel;
import 'package:dawarich/features/stats/presentation/models/countries/visited_country_uimodel.dart';

final class VisitedCountriesUiModel {
  final List<VisitedCountryUiModel> countries;
  final List<VisitedCityFlatUiModel> citiesFlat;

  const VisitedCountriesUiModel({
    required this.countries,
    required this.citiesFlat,
  });
}