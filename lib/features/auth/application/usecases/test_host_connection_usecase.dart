
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/application/repositories/connect_repository_interfaces.dart';
import 'package:flutter/foundation.dart';

final class TestHostConnectionUseCase {

  final IApiConfigManager _apiConfigManager;
  final IConnectRepository _connectRepository;

  TestHostConnectionUseCase(this._apiConfigManager, this._connectRepository);

  Future<bool> call(String host) async {
    host = host.trim();

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    // If user explicitly specified a protocol, use it as-is
    if (host.startsWith("http://") || host.startsWith("https://")) {
      _apiConfigManager.createConfig(host);
      return _connectRepository.testHost(host);
    }

    // No protocol specified - try HTTPS first, then HTTP
    final httpsUrl = "https://$host";
    _apiConfigManager.createConfig(httpsUrl);

    if (await _connectRepository.testHost(httpsUrl)) {
      return true;
    }

    // HTTPS failed, try HTTP (common for local IP addresses)
    if (kDebugMode) {
      debugPrint("[TestHost] HTTPS failed, trying HTTP for: $host");
    }

    final httpUrl = "http://$host";
    _apiConfigManager.createConfig(httpUrl);
    return _connectRepository.testHost(httpUrl);
  }
}