
import 'package:dawarich/data_contracts/interfaces/api_config_manager_interfaces.dart';

class ApiConfigService {
  final IApiConfigLogout _repository;
  ApiConfigService(this._repository);


  Future<void> clearApiConfig() async {
    await _repository.clearConfiguration();
  }
}
