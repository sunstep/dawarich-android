import 'package:dawarich/core/network/configs/api_endpoints.dart';
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/core/network/errors/remote_request_failure.dart';
import 'package:dawarich/core/network/repositories/points_order.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/point/upload/dawarich_point_batch_dto.dart';
import 'package:dawarich/core/point_data/data/data_transfer_objects/api/api_point_dto.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/timeline/data/data_transfer_objects/slim_api_point_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';

final class ApiPointRepository implements IApiPointRepository {

  final DioClient _apiClient;
  ApiPointRepository(this._apiClient);

  @override
  Future<Result<(), String>> uploadBatch(DawarichPointBatchDto batch) async {
    try {
      final response = await _apiClient.post<void>(
          '/api/v1/points',
          data: batch.toJson(),
          queryParameters: {},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ));

      if (response.statusCode == 200) {
        return const Ok(());
      } else {
        return Err('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // network / timeout / cancellation / 4xx/5xx
      return Err(e.message ?? 'The API rejected the batch.');
    }
  }

  @override
  Future<Option<List<ApiPointDTO>>> getPoints({
    required DateTime startDate,
    required DateTime endDate,
    required int perPage,
    PointsOrder order = PointsOrder.descending
  }) async {
    final startIso = _formatStartDate(startDate);
    final endIso   = _formatEndDate(endDate);

    try {
      final headResp = await _apiClient.head<Map<String, String?>>(
        '/api/v1/points',
        queryParameters: {
          'start_at': startIso,
          'end_at':   endIso,
          'per_page': perPage,
          'order':    order == PointsOrder.ascending ? 'asc' : 'desc',
        },
      );

      final totalPages = int.tryParse(
        headResp.headers.value('x-total-pages') ?? '',
      ) ?? 0;

      if (totalPages == 0) {
        return const Some(<ApiPointDTO>[]);
      }

      final allPoints = await _fetchAllFullPagesThrottled(
        totalPages: totalPages,
        startIso: startIso,
        endIso: endIso,
        perPage: perPage,
        order: order,
      );

      return Some(allPoints);
    } catch (e, st) {
      debugPrint('Failed to fetch all points: $e\n$st');
      return const None();
    }
  }

  @override
  Future<Option<List<SlimApiPointDTO>>> getSlimPoints({
    required DateTime startDate,
    required DateTime endDate,
    required int perPage,
    PointsOrder order = PointsOrder.descending
  }) async {
    final startIso = _formatStartDate(startDate);
    final endIso   = _formatEndDate(endDate);

    try {

      final Result<Response<Map<String, String?>>, RemoteRequestFailure> headRespResult = await _apiClient.safe(() async {
        return await _apiClient.head<Map<String, String?>>(
          ApiEndpoints.getPoints,
          queryParameters: {
            'start_at': startIso,
            'end_at':   endIso,
            'per_page': perPage,
            'slim':     true,
            'order':    order == PointsOrder.ascending ? 'asc' : 'desc',
          },
        );
      });

      if (headRespResult case Err(value: final RemoteRequestFailure failure)) {
        debugPrint('Failed to fetch all points: ${failure.userMessage}');
        return const None();
      }

      final Response<Map<String, String?>> headResp = headRespResult.unwrap();

      final totalPages = int.tryParse(
        headResp.headers.value('x-total-pages') ?? '',
      ) ?? 0;

      if (totalPages == 0) {
        return const Some(<SlimApiPointDTO>[]);
      }


      final allPoints = await _fetchAllPagesThrottled(
        totalPages: totalPages,
        startIso: startIso,
        endIso: endIso,
        perPage: perPage,
        order: order,
      );

      return Some(allPoints);
    } catch (e, st) {
      debugPrint('Failed to fetch all points: $e\n$st');
      return const None();
    }
  }

  Future<List<SlimApiPointDTO>> _fetchAllPagesThrottled({
    required int totalPages,
    required String startIso,
    required String endIso,
    required int perPage,
    PointsOrder order = PointsOrder.descending,
    int maxConcurrent = 5,
  }) async {
    final results = <SlimApiPointDTO>[];
    final queue = List<int>.generate(totalPages, (i) => i + 1);
    final active = <Future<void>>[];

    Future<void> handlePage(int pageNumber) async {
      try {
        final resp = await _apiClient
            .get<List<dynamic>>(
          '/api/v1/points',
          queryParameters: {
            'start_at': startIso,
            'end_at': endIso,
            'per_page': perPage,
            'page': pageNumber,
            'slim': true,
            'order': order == PointsOrder.ascending ? 'asc' : 'desc',
          },
        )
            .timeout(const Duration(seconds: 15));
        final points = resp.data!
            .map((e) => SlimApiPointDTO.fromJson(e))
            .toList();
        results.addAll(points);
      } catch (e, st) {
        debugPrint('⚠️ Failed page $pageNumber: $e\n$st');
      }
    }

    while (queue.isNotEmpty || active.isNotEmpty) {
      while (active.length < maxConcurrent && queue.isNotEmpty) {
        final page = queue.removeAt(0);
        final future = handlePage(page);
        active.add(future);
        future.whenComplete(() => active.remove(future));
      }
      if (active.isNotEmpty) {
        await Future.any(active);
      }
    }

    return results;
  }

  Future<List<ApiPointDTO>> _fetchAllFullPagesThrottled({
    required int totalPages,
    required String startIso,
    required String endIso,
    required int perPage,
    PointsOrder order = PointsOrder.descending,
    int maxConcurrent = 5,
    Duration perPageTimeout = const Duration(seconds: 25),
    int maxAttempts = 2,
  }) async {
    final results = <ApiPointDTO>[];
    final queue = List<int>.generate(totalPages, (i) => i + 1);
    final active = <Future<void>>[];

    bool isRetryable(Object e) {
      if (e is DioException) {
        return e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError;
      }
      return false;
    }

    Future<void> handlePage(int pageNumber) async {
      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          final resp = await _apiClient
              .get<List<dynamic>>(
            '/api/v1/points',
            queryParameters: {
              'start_at': startIso,
              'end_at': endIso,
              'per_page': perPage,
              'page': pageNumber,
              'order': order == PointsOrder.ascending ? 'asc' : 'desc',
            },
          )
              .timeout(perPageTimeout);

          final points = resp.data!
              .map((json) => ApiPointDTO(json as Map<String, dynamic>))
              .toList();
          results.addAll(points);
          return;
        } catch (e, st) {
          final retryable = isRetryable(e);
          final isLastAttempt = attempt >= maxAttempts;
          debugPrint(
            'Error fetching points page $pageNumber (attempt $attempt/$maxAttempts): $e\n$st',
          );
          if (!retryable || isLastAttempt) {
            return;
          }
          // small backoff to avoid hammering the server
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }

    while (queue.isNotEmpty || active.isNotEmpty) {
      while (active.length < maxConcurrent && queue.isNotEmpty) {
        final page = queue.removeAt(0);
        final future = handlePage(page);
        active.add(future);
        future.whenComplete(() => active.remove(future));
      }
      if (active.isNotEmpty) {
        await Future.any(active);
      }
    }

    return results;
  }

  @override
  Future<int> getTotalPages({
    required DateTime startDate,
    required DateTime endDate,
    required int perPage,
  }) async {
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
  Future<Option<ApiPointDTO>> fetchLastPoint({DateTime? start, DateTime? end}) async {

    try {

      final qp = {
        'per_page': 1,
        'page':     1,
        'order':    'desc',
      };

      if (start != null && end != null) {
        qp['start_at'] = _formatStartDate(start);
        qp['end_at']   = _formatEndDate(end);
      }

      final resp = await _apiClient.get<List<dynamic>>(
        '/api/v1/points',
        queryParameters: qp,
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
  Future<Option<SlimApiPointDTO>> fetchLastSlimPoint({DateTime? start, DateTime? end}) async {
    try {

      final qp = {
        'per_page': 1,
        'page':     1,
        'slim':     true,
        'order':    'desc',
      };

      if (start != null && end != null) {
        qp['start_at'] = _formatStartDate(start);
        qp['end_at']   = _formatEndDate(end);
      }

      final resp = await _apiClient.get<List<dynamic>>(
        '/api/v1/points',
        queryParameters: qp,
      );

      final data = resp.data;
      if (data == null || data.isEmpty) {
        return const None();
      }

      final dto = SlimApiPointDTO.fromJson(data.first as Map<String, dynamic>);
      return Some(dto);
    } on DioException catch (e) {
      debugPrint('Failed to fetch last slim point: ${e.message}');
      return const None();
    }
  }

  @override
  Future<Option<SlimApiPointDTO>> fetchLastSlimPointForDay(DateTime day) {
    final startLocal = DateTime(day.year, day.month, day.day);
    final endLocal   = startLocal.add(const Duration(days: 1)); // [start, nextStart)
    return fetchLastSlimPoint(start: startLocal, end: endLocal);
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

  String _formatStartDate(DateTime date) => date.toUtc().toIso8601String();
  String _formatEndDate(DateTime date) => date.toUtc().toIso8601String();
}
