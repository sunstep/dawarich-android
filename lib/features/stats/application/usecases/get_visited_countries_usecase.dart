
import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/features/stats/application/queries/countries_query.dart';
import 'package:dawarich/features/stats/application/repositories/countries_repository_interfaces.dart';
import 'package:dawarich/features/stats/domain/countries/visited_countries.dart';
import 'package:option_result/result.dart';

final class GetVisitedCountriesUseCase {
  final ICountriesRepository _repo;

  GetVisitedCountriesUseCase(this._repo);

  Future<Result<VisitedCountries, Failure>> call({
    required CountriesQuery query,
  }) async {
    final validation = _validate(query);
    if (validation != null) {
      return Err(validation);
    }

    return _repo.getCountries(query: query);
  }

  Failure? _validate(CountriesQuery query) {
    if (!query.isValidRange) {
      return Failure(
        kind: FailureKind.validation,
        code: 'INVALID_DATE_RANGE',
        message: '`endAt` must be the same as or after `startAt`.',
        context: const {'where': 'GetVisitedCountriesUseCase'},
      );
    }

    return null;
  }
}