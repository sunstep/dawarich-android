
abstract interface class IConnectRepository {

  Future<bool> testHost();
  Future<bool> tryApiKey();
}