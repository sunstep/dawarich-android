
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/application/repositories/connect_repository_interfaces.dart';

final class TestHostConnectionUseCase {

  final IApiConfigManager _apiConfigManager;
  final IConnectRepository _connectRepository;

  TestHostConnectionUseCase(this._apiConfigManager, this._connectRepository);

  Future<bool> call(String host) async {
    host = host.trim();

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    String fullUrl = _ensureProtocol(host, isHttps: true);

    _apiConfigManager.createConfig(fullUrl);
    return _connectRepository.testHost(fullUrl);
  }


  String _ensureProtocol(String host, {required bool isHttps}) {
    if (!host.startsWith("http://") && !host.startsWith("https://")) {
      return isHttps ? "https://$host" : "http://$host";
    }

    return host;
  }

}