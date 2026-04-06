import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:dawarich/features/stats/data/data_transfer_objects/countries/visited_city_dto.dart';
import 'package:dawarich/features/stats/data/data_transfer_objects/countries/visited_countries_dto.dart';
import 'package:dawarich/features/stats/data/data_transfer_objects/countries/visited_country_dto.dart';
import 'package:dawarich/features/stats/domain/countries/visited_city.dart';
import 'package:dawarich/features/stats/domain/countries/visited_countries.dart';
import 'package:dawarich/features/stats/domain/countries/visited_country.dart';


import 'countries_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<VisitedCountriesDto, VisitedCountries>(),
  MapType<VisitedCountryDto, VisitedCountry>(),
  MapType<VisitedCityDto, VisitedCity>()
],
converters: [
    TypeConverter<int, DateTime>(VisitedCountriesDataMapper.unixSecondsToDateTime),
    TypeConverter<int, Duration>(VisitedCountriesDataMapper.secondsToDuration),
    ])
class VisitedCountriesDataMapper extends $VisitedCountriesDataMapper {
  const VisitedCountriesDataMapper();


  static DateTime unixSecondsToDateTime(int seconds) {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  static Duration secondsToDuration(int seconds) {
    return Duration(seconds: seconds);
  }
}