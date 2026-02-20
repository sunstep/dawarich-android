
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/application/converters/user_converter.dart';
import 'package:dawarich/features/auth/application/repositories/connect_repository_interfaces.dart';
import 'package:dawarich/features/auth/application/repositories/user_repository_interfaces.dart';
import 'package:dawarich/features/auth/data/data_transfer_objects/users/user_dto.dart';
import 'package:dawarich_android_user_module/dawarich_android_user_module.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class LoginWithApiKeyUseCase {

  final IConnectRepository _connectRepository;
  final IApiConfigManager _apiConfigManager;
  final IUserRepository _userStorageRepository;
  final DawarichAndroidUserModule<User> _userSession;

  LoginWithApiKeyUseCase(this._connectRepository, this._apiConfigManager,
      this._userStorageRepository, this._userSession);

  Future<bool> call(String apiKey) async {

    apiKey = apiKey.trim();
    _apiConfigManager.setApiKey(apiKey);

    Result<UserDto, String> loginResult =
    await _connectRepository.loginApiKey(apiKey);

    if (loginResult case Ok(value: UserDto userDto)) {
      await _apiConfigManager.storeApiConfig();
      final User user = userDto.toDomain();
      int userId = await _userStorageRepository.storeUser(user);
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
}