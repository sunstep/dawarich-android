import 'package:dawarich/data/dawarich_api/sources/api_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/stats/response/stats_dto.dart';
import 'package:dawarich/data_contracts/interfaces/stats_repository_interfaces.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';

final class StatsRepository implements IStatsRepository {
  final ApiClient _apiClient;
  StatsRepository(this._apiClient);

  @override
  Future<Option<StatsDTO>> getStats() async {
    try {
      final resp = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/stats',
      );

      final json = resp.data;
      if (json == null || json.isEmpty) {
        return const None();
      }

      // 2) Map to your DTO and return
      final stats = StatsDTO.fromJson(json);
      return Some(stats);
    } on DioException catch (e) {
      debugPrint('Failed to retrieve stats: ${e.message}');
      return const None();
    }
  }
}
