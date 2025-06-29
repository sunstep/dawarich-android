import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/upload/dawarich_point_batch_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/api/api_point_dto.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/timeline/data_contracts/data_transfer_objects/slim_api_point_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';

final class ApiPointRepository implements IApiPointRepository {

  final DioClient _apiClient;
  ApiPointRepository(this._apiClient);

  @override
  Future<Result<(), String>> uploadBatch(DawarichPointBatchDto batch) async {
    try {
      final response = await _apiClient
          .post<void>('/api/v1/points', data: batch, queryParameters: {});

      if (response.statusCode == 201) {
        return const Ok(());
      } else {
        return Err('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // network / timeout / cancellation / 4xx/5xx
      return Err(e.message ?? 'Unknown network error');
    }
  }

  @override
  Future<Option<List<ApiPointDTO>>> fetchPoints(
      DateTime startDate,
      DateTime endDate,
      int perPage,
      ) async {
    final startIso = _formatStartDate(startDate);
    final endIso   = _formatEndDate(endDate);

    try {
      final headResp = await _apiClient.head<Map<String, String?>>(
        '/api/v1/points',
        queryParameters: {
          'start_at': startIso,
          'end_at':   endIso,
          'per_page': perPage,
        },
      );

      final totalPages = int.tryParse(
        headResp.headers.value('x-total-pages') ?? '',
      ) ?? 0;

      if (totalPages == 0) {
        return const Some(<ApiPointDTO>[]);
      }

      final pageFutures = List<Future<List<ApiPointDTO>>>.generate(
        totalPages,
            (i) async {
          final pageNumber = i + 1;
          try {
            final resp = await _apiClient.get<List<dynamic>>(
              '/api/v1/points',
              queryParameters: {
                'start_at': startIso,
                'end_at':   endIso,
                'per_page': perPage,
                'page':     pageNumber,
              },
            );

            return resp.data!
                .map((json) => ApiPointDTO(
                json as Map<String, dynamic>))
                .toList();
          } catch (e, st) {
            debugPrint('Error fetching points page $pageNumber: $e\n$st');
            return <ApiPointDTO>[];
          }
        },
      );

      final pages = await Future.wait(pageFutures);
      final allPoints = pages.expand((list) => list).toList();

      return Some(allPoints);
    } catch (e, st) {
      debugPrint('Failed to fetch all points: $e\n$st');
      return const None();
    }
  }

  @override
  Future<Option<List<SlimApiPointDTO>>> fetchSlimPoints(
      DateTime startDate,
      DateTime endDate,
      int perPage,
      ) async {
    final startIso = _formatStartDate(startDate);
    final endIso   = _formatEndDate(endDate);

    try {
      final headResp = await _apiClient.head<Map<String, String?>>(
        '/api/v1/points',
        queryParameters: {
          'start_at': startIso,
          'end_at':   endIso,
          'per_page': perPage,
          'slim':     true
        },
      );

      final totalPages = int.tryParse(
        headResp.headers.value('x-total-pages') ?? '',
      ) ?? 0;

      if (totalPages == 0) {
        return const Some(<SlimApiPointDTO>[]);
      }

      final pageFutures = List<Future<List<SlimApiPointDTO>>>.generate(
        totalPages,
            (i) async {
          final pageNumber = i + 1;
          try {
            final resp = await _apiClient.get<List<dynamic>>(
              '/api/v1/points',
              queryParameters: {
                'start_at': startIso,
                'end_at':   endIso,
                'per_page': perPage,
                'page':     pageNumber,
                'slim':     true
              },
            );

            return resp.data!
                .map((json) => SlimApiPointDTO(
                json as Map<String, dynamic>))
                .toList();
          } catch (e, st) {
            debugPrint('Error fetching points page $pageNumber: $e\n$st');
            return <SlimApiPointDTO>[];
          }
        },
      );

      final pages = await Future.wait(pageFutures);
      final allPoints = pages.expand((list) => list).toList();

      return Some(allPoints);
    } catch (e, st) {
      debugPrint('Failed to fetch all points: $e\n$st');
      return const None();
    }
  }

  @override
  Future<int> getTotalPages(
      DateTime startDate,
      DateTime endDate,
      int perPage,
      ) async {
    final startIso = _formatStartDate(startDate);
    final endIso   = _formatEndDate(endDate);

    try {
      final headResp = await _apiClient.head<Map<String, String?>>(
        '/api/v1/points',
        queryParameters: {
          'start_at': startIso,
          'end_at':   endIso,
          'per_page': perPage,
        },
      );

      final totalPagesHeader = headResp.headers.value('x-total-pages');

      return totalPagesHeader != null
          ? int.parse(totalPagesHeader)
          : 0;
    } on DioException catch (e) {
      debugPrint('Failed to get total pages: ${e.message}');
      return 0;
    }
  }

  @override
  Future<Option<ApiPointDTO>> fetchLastPoint() async {

    try {

      final resp = await _apiClient.get<List<dynamic>>(
        '/api/v1/points',
        queryParameters: {
          'per_page': 1,
          'page':     1,
          'order':    'desc',
        },
      );

      final data = resp.data;
      if (data == null || data.isEmpty) {
        return const None();
      }

      final dto = ApiPointDTO(data.first as Map<String, dynamic>);
      return Some(dto);
    } on DioException catch (e) {
      debugPrint('Failed to fetch last point: ${e.message}');
      return const None();
    }
  }

  @override
  Future<Result<(), String>> deletePoint(String id) async {
    try {
      final resp = await _apiClient.delete<void>(
        '/api/v1/points/$id',
      );

      if (resp.statusCode == 200) {
        return const Ok(());              // success
      } else {
        return Err(
          'HTTP ${resp.statusCode}: ${resp.statusMessage}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Failed to delete point: ${e.message}');
      return Err(e.message ?? 'Failed to delete point.');
    }
  }

  String _formatStartDate(DateTime date) {
    return DateTime(date.year, date.month, date.day).toUtc().toIso8601String();
  }

  String _formatEndDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59)
        .toUtc()
        .toIso8601String();
  }
}
