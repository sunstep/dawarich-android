import 'package:dawarich/core/shell/drawer/i_api_config_logout.dart';

class ApiConfigService {
  final IApiConfigLogout _repository;
  ApiConfigService(this._repository);


  Future<void> clearApiConfig() async {
    await _repository.clearConfiguration();
  }
}
