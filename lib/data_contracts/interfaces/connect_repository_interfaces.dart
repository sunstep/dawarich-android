
abstract interface class IConnectRepository {

  Future<bool> testHost(String host);
  Future<bool> tryApiKey(String apiKey);
}