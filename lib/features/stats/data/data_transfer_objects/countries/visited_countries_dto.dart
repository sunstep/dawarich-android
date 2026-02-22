
import 'package:dawarich/features/stats/data/data_transfer_objects/countries/visited_country_dto.dart';

final class VisitedCountriesDto {

  final List<VisitedCountryDto> data;

  const VisitedCountriesDto({required this.data});

  factory VisitedCountriesDto.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];

    if (raw is! List) {
      return const VisitedCountriesDto(data: []);
    }

    return VisitedCountriesDto(
      data: raw
          .whereType<Map<String, dynamic>>()
          .map(VisitedCountryDto.fromJson)
          .toList(),
    );
  }
}