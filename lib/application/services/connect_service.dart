import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/user_session_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/user_storage_repository_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class ConnectService {
  final IConnectRepository _connectRepository;
  final IApiConfigRepository _apiConfigRepository;
  final IUserStorageRepository _userStorageRepository;
  final IUserSessionRepository _userSession;

  ConnectService(
      this._connectRepository, this._apiConfigRepository, this._userStorageRepository, this._userSession);

  Future<bool> testHost(String host) async {
    host = host.trim();

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    String fullUrl = _ensureProtocol(host, isHttps: true);
    return _connectRepository.testHost(fullUrl);
  }

  Future<bool> loginApiKey(String apiKey) async {
    apiKey = apiKey.trim();
    Result<UserDto, String> loginResult =
        await _connectRepository.loginApiKey(apiKey);

    if (loginResult case Ok(value: UserDto userDto)) {
      final int userId = await _userStorageRepository.storeUser(userDto);
      await _apiConfigRepository.storeApiConfig();
      await _userSession.setCurrentUserId(userId);
      return true;
    }

    final String error = loginResult.unwrapErr();

    if (kDebugMode) {
      debugPrint("[DEBUG] Login with API key failed: $error");
    }

    return false;
  }

  String _ensureProtocol(String host, {required bool isHttps}) {
    if (!host.startsWith("http://") && !host.startsWith("https://")) {
      return isHttps ? "https://$host" : "http://$host";
    }

    return host;
  }
}
