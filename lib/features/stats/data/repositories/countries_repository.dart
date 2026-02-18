
import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/stats/application/queries/countries_query.dart';
import 'package:dawarich/features/stats/application/repositories/countries_repository_interfaces.dart';
import 'package:dawarich/features/stats/data/data_transfer_objects/countries/visited_countries_dto.dart';
import 'package:dawarich/features/stats/data/mappers/countries_mapper.dart';
import 'package:dawarich/features/stats/domain/countries/visited_countries.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class CountriesRepository implements ICountriesRepository {

  final DioClient _apiClient;
  final VisitedCountriesDataMapper _mapper;
  CountriesRepository(this._apiClient, this._mapper);

  @override
  Future<Result<VisitedCountries, Failure>> getCountries({required CountriesQuery query}) async {
    try {

      final resp = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/countries/visited_cities',
        queryParameters: query.toUrlQuery(),
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final json = resp.data;
      if (json == null || json.isEmpty) {
        return Err(
          Failure(
            kind: FailureKind.validation,
            code: 'EMPTY_RESPONSE',
            message: 'Countries stats response was empty.',
            context: const {'where': 'CountriesRepository.getCountries'},
          ),
        );
      }

      final dto = VisitedCountriesDto.fromJson(json);
      final mapped = _mapper.convert(dto);
      return Ok(mapped);
    } on DioException catch (e, s) {
      debugPrint('[CountriesRepository] Dio error: ${e.message}');
      return Err(
        Failure(
          kind: FailureKind.network,
          code: 'DIO_EXCEPTION',
          message: e.message ?? 'Request failed.',
          context: {
            'where': 'CountriesRepository.getCountries',
            'type': e.type.toString(),
            'statusCode': e.response?.statusCode,
          },
          stackTrace: s,
        ),
      );
    } catch (e, s) {
      debugPrint('[CountriesRepository] Unexpected error: $e');
      return Err(
        Failure(
          kind: FailureKind.unknown,
          code: 'UNEXPECTED',
          message: e.toString(),
          context: const {'where': 'CountriesRepository.getCountries'},
          stackTrace: s,
        ),
      );
    }
  }



}