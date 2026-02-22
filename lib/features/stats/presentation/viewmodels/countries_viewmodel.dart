import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/features/stats/application/queries/countries_query.dart';
import 'package:dawarich/features/stats/application/usecases/get_visited_countries_usecase.dart';
import 'package:dawarich/features/stats/presentation/converters/countries_mapper.dart';
import 'package:dawarich/features/stats/presentation/models/countries/visited_countries_uimodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:option_result/option_result.dart';


final countriesViewmodelProvider =
AsyncNotifierProvider<CountriesViewmodel, Result<VisitedCountriesUiModel?, Failure>>(
  CountriesViewmodel.new,
);

final class CountriesViewmodel extends AsyncNotifier<Result<VisitedCountriesUiModel?, Failure>> {
  CountriesQuery? _lastQuery;

  @override
  Future<Result<VisitedCountriesUiModel?, Failure>> build() async {

    if (kDebugMode) {
      debugPrint('[CountriesViewmodel] build called');
    }

    final useCase = await ref.read(getVisitedCountriesUseCaseProvider.future);
    final mapper = ref.read(countriesUiMapperProvider);

    final query = CountriesQuery(
      startAt: DateTime.utc(1970, 1, 1),
      endAt: DateTime.now().toUtc(),
    );

    _lastQuery = query;
    return await _fetchCountries(useCase, mapper, query);
  }

  Future<Result<VisitedCountriesUiModel?, Failure>> _fetchCountries(
      GetVisitedCountriesUseCase useCase,
      VisitedCountriesUiMapper mapper,
      CountriesQuery query,
      ) async {
    final result = await useCase(query: query);

    if (result case Ok(value: final countries)) {
      return Ok(mapper.convert(countries));
    }

    if (result case Err(value: final failure)) {
      if (kDebugMode) {
        debugPrint('[CountriesViewmodel] getCountries failed: ${failure.message}');
      }
      return Err(failure);
    }

    return const Ok(null);
  }

  Future<void> refresh() async {

    if (kDebugMode) {
      debugPrint('[CountriesViewmodel] refresh() called');
      debugPrint(StackTrace.current.toString());
    }

    final query = _lastQuery ??
        CountriesQuery(
          startAt: DateTime.utc(1970, 1, 1),
          endAt: DateTime.now().toUtc(),
        );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = await ref.read(getVisitedCountriesUseCaseProvider.future);
      final mapper = ref.read(countriesUiMapperProvider);
      return _fetchCountries(useCase, mapper, query);
    });
  }

  Future<void> setQuery(CountriesQuery query) async {
    _lastQuery = query;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = await ref.read(getVisitedCountriesUseCaseProvider.future);
      final mapper = ref.read(countriesUiMapperProvider);
      return _fetchCountries(useCase, mapper, query);
    });
  }
}