import 'dart:convert';
import 'dart:io';
import 'package:dawarich/data/sources/api/v1/users/users_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/health/response/health_dto.dart';
import 'package:option_result/option_result.dart';

final class ConnectRepository implements IConnectRepository {

  final IApiConfigRepository _apiConfig;
  final UsersApiClient _usersApiClient;

  ConnectRepository(this._apiConfig, this._usersApiClient);

  @override
  Future<bool> testHost(String host) async {

    try {

      _apiConfig.setHost(host);

      final Uri uri = Uri.parse("$host/api/v1/health");
      final Response response = await get(uri);

      if (response.statusCode == 200) {
        final dynamic resultBody = jsonDecode(response.body);
        final HealthDto health = HealthDto(resultBody);
        String? dawarichResponse = response.headers["x-dawarich-response"];

        return health.status == "ok" && dawarichResponse == "Hey, I'm alive!";
      } else {

        if (kDebugMode){
          debugPrint("Host gave a status code other than 200: ${response.reasonPhrase}");
        }

        return false;
      }
    } on SocketException catch (e) {

      if (kDebugMode) {
        debugPrint("SocketException: ${e.message}");
      }

      return false;
    } catch (e) {

      if (kDebugMode) {
        debugPrint("Error in testHost: $e");
      }

      return false;
    }
  }

  @override
  Future<Result<UserDto, String>> loginApiKey(String apiKey) async {

    _apiConfig.setApiKey(apiKey);
    final Result<UserDto, String> result = await _usersApiClient.getUser();

    if (result case Ok(value: UserDto user)) {
      return Ok(user);
    }

    final String error = result.unwrapErr();

    if (kDebugMode) {
      debugPrint("Api key verification failed: $error");
    }

    return Err(error);

  }

}