import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';

class ApiConfigService {

  final IApiConfigRepository _repository;
  ApiConfigService(this._repository);

  Future<void> initialize() async {
    await _repository.initialize();
  }

  bool isConfigured() {
    return _repository.isConfigured();
  }

  Future<void> clearApiConfig() async {
    await _repository.clearConfiguration();
  }

}