
import 'package:dawarich/data/sources/local/secure_storage/api_config_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';

final class ApiConfigRepository implements IApiConfigRepository {

  final ApiConfigClient _apiConfigClient;
  ApiConfigRepository(this._apiConfigClient);

  @override
  Future<void> initialize() async {
    await _apiConfigClient.initialize();
  }

  @override
  Future<void> setHost(String host) async {
    await _apiConfigClient.setHost(host);
  }

  @override
  Future<void> setApiKey(String apiKey) async {
    await _apiConfigClient.setApiKey(apiKey);
  }

  @override
  ApiConfigDTO getApiConfig() {
    return _apiConfigClient.getApiConfig();
  }

  @override
  Future<void> storeApiConfig() async  {
    await _apiConfigClient.storeApiConfig();
  }

  @override
  Future<void> clearConfiguration() async {
    await _apiConfigClient.clearConfiguration();
  }

  @override
  bool isConfigured() {
    return _apiConfigClient.isConfigured();
  }

}