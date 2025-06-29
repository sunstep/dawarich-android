 import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/session/user_session_service.dart';
import 'package:dawarich/features/auth/data_contracts/data_transfer_objects/users/user_dto.dart';
import 'package:dawarich/core/network/api_config/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dawarich/core/session/legacy_user_session_repository_interfaces.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/user_storage_repository_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import 'package:user_session_manager/user_session_manager.dart';

final class ConnectService {
  final IConnectRepository _connectRepository;
  final IApiConfigManager _apiConfigManager;
  final IUserStorageRepository _userStorageRepository;
  final UserSessionManager<int> _userSession;

  ConnectService(this._connectRepository, this._apiConfigManager,
      this._userStorageRepository, this._userSession);

  Future<bool> testHost(String host) async {
    host = host.trim();

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    String fullUrl = _ensureProtocol(host, isHttps: true);

    _apiConfigManager.createConfig(fullUrl);
    return _connectRepository.testHost(fullUrl);
  }

  Future<bool> loginApiKey(String apiKey) async {

    apiKey = apiKey.trim();
    _apiConfigManager.setApiKey(apiKey);

    Result<UserDto, String> loginResult =
        await _connectRepository.loginApiKey(apiKey);

    if (loginResult case Ok(value: UserDto userDto)) {
      final int userId = await _userStorageRepository.storeUser(userDto);
      await _apiConfigManager.storeApiConfig();
      await _userSession.login(userId);
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
