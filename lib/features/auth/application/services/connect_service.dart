import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/auth/application/converters/user_converter.dart';
import 'package:dawarich/features/auth/data_contracts/data_transfer_objects/users/user_dto.dart';
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/application/repositories/connect_repository_interfaces.dart';
import 'package:dawarich/features/auth/application/repositories/user_repository_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import 'package:session_box/session_box.dart';

final class ConnectService {
  final IConnectRepository _connectRepository;
  final IApiConfigManager _apiConfigManager;
  final IUserRepository _userStorageRepository;
  final SessionBox<User> _userSession;

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
      await _apiConfigManager.storeApiConfig();
      int userId = await _userStorageRepository.storeUser(userDto);
      final User user = userDto.toDomain();
      user.addUserId(userId);
      await _userSession.login(user);
      _userSession.setUserId(userId);
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
