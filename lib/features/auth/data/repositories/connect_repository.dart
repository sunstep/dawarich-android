import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/auth/data_contracts/data_transfer_objects/users/user_dto.dart';
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/application/repositories/connect_repository_interfaces.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dawarich/features/auth/data_contracts/data_transfer_objects/health/health_dto.dart';
import 'package:option_result/option_result.dart';

final class ConnectRepository implements IConnectRepository {
  final IApiConfigManager _apiConfig;
  final DioClient _apiClient;

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

      var user = UserDto.fromRemote(userJson)
          .withDawarichEndpoint(_apiConfig.apiConfig?.host);

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
