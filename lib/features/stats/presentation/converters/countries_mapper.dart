import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:dawarich/features/stats/domain/countries/visited_city.dart';
import 'package:dawarich/features/stats/domain/countries/visited_countries.dart';
import 'package:dawarich/features/stats/domain/countries/visited_country.dart';

import 'package:dawarich/features/stats/presentation/models/countries/visited_city_flat_uimodel.dart';
import 'package:dawarich/features/stats/presentation/models/countries/visited_city_uimodel.dart';
import 'package:dawarich/features/stats/presentation/models/countries/visited_countries_uimodel.dart';
import 'package:dawarich/features/stats/presentation/models/countries/visited_country_uimodel.dart';

import 'countries_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<VisitedCountries, VisitedCountriesUiModel>(),
  MapType<VisitedCountry, VisitedCountryUiModel>(),
  MapType<VisitedCity, VisitedCityUIModel>(),
])
class VisitedCountriesUiMapper extends $VisitedCountriesUiMapper {
  const VisitedCountriesUiMapper();

  VisitedCountriesUiModel toUi(VisitedCountries domain) {
    final countries = domain.data
        .map((c) => convert<VisitedCountry, VisitedCountryUiModel>(c))
        .toList();

    final citiesFlat = <VisitedCityFlatUiModel>[
      for (final c in countries)
        for (final city in c.cities)
          VisitedCityFlatUiModel(
            country: c.country,
            city: city.city,
            points: city.points,
            lastSeenAt: city.timestamp,
            stayedFor: city.stayedFor,
          ),
    ];

    return VisitedCountriesUiModel(
      countries: countries,
      citiesFlat: citiesFlat,
    );
  }
}