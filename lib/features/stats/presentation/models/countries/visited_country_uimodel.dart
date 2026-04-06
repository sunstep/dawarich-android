
import 'package:dawarich/features/stats/presentation/models/countries/visited_city_uimodel.dart';

final class VisitedCountryUiModel {

  final String country;
  final List<VisitedCityUIModel> cities;


  const VisitedCountryUiModel({required this.country, required this.cities});

}