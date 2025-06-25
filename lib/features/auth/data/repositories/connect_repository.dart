import 'package:dawarich/core/data/dawarich_api/sources/api_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/health/response/health_dto.dart';
import 'package:option_result/option_result.dart';

final class ConnectRepository implements IConnectRepository {
  final IApiConfigManager _apiConfig;
  final ApiClient _apiClient;

  ConnectRepository(this._apiConfig, this._apiClient);

  @override
  Future<bool> testHost(String host) async {

    try {
      final resp = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/health',
      );

      final health = HealthDto(resp.data!);

      final dawarichResponse =
      resp.headers.value('x-dawarich-response');

      return health.status == 'ok'
          && dawarichResponse == "Hey, I'm alive!";
    } on DioException catch (e) {
      if (kDebugMode) debugPrint("Health check failed: ${e.message}");
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint("Error in testHost: $e");
      return false;
    }
  }

  @override
  Future<Result<UserDto, String>> loginApiKey(String apiKey) async {

    try {
      final resp = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/users/me',
      );

      final userJson = resp.data!['user'] as Map<String, dynamic>;

      var user = UserDto.fromJson(userJson);

      user = user.withDawarichEndpoint(_apiConfig.apiConfig?.host);

      return Ok(user);
    } on DioException catch (e) {
      if (kDebugMode) debugPrint("Api key verification failed: ${e.message}");
      return Err(e.message ?? 'Failed to verify API key');
    } catch (e) {
      if (kDebugMode) debugPrint("Error while fetching user data: $e");
      return Err("Error while fetching user data: $e");
    }
  }
}
