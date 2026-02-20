import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/features/stats/application/queries/countries_query.dart';
import 'package:dawarich/features/stats/domain/countries/visited_countries.dart';
import 'package:option_result/option_result.dart';

abstract interface class ICountriesRepository {
  /// Fetches the list of countries from the API.
  Future<Result<VisitedCountries, Failure>> getCountries({required CountriesQuery query});
}