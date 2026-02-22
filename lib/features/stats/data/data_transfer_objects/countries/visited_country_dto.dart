
import 'package:dawarich/features/stats/data/data_transfer_objects/countries/visited_city_dto.dart';

final class VisitedCountryDto {

  final String country;
  final List<VisitedCityDto> cities;

  const VisitedCountryDto({required this.country, required this.cities});

  factory VisitedCountryDto.fromJson(Map<String, dynamic> json) {
    final countryRaw = json['country'];
    final citiesRaw = json['cities'];

    final country = countryRaw is String ? countryRaw : '';

    final cities = (citiesRaw is List)
        ? citiesRaw
        .whereType<Map<String, dynamic>>()
        .map(VisitedCityDto.fromJson)
        .toList()
        : <VisitedCityDto>[];

    return VisitedCountryDto(country: country, cities: cities);
  }
}