import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/stats/data/data_transfer_objects/stats/stats_dto.dart';
import 'package:dawarich/features/stats/application/repositories/stats_repository_interfaces.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';

final class StatsRepository implements IStatsRepository {
  final DioClient _apiClient;
  StatsRepository(this._apiClient);

  @override
  Future<Option<StatsDTO>> getStats() async {
    try {
      final resp = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/stats',
        options: Options(
          receiveTimeout: const Duration(seconds: 30)
        )
      );

      final Map<String, dynamic>? json = resp.data;
      if (json == null || json.isEmpty) {
        return const None();
      }

      final StatsDTO stats = StatsDTO.fromJson(json);
      return Some(stats);
    } on DioException catch (e) {
      debugPrint('Failed to retrieve stats: ${e.message}');
      return const None();
    }
  }
}
