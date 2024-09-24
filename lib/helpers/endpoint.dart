import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EndpointResult with ChangeNotifier{
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? endPoint;
  String? apiKey;

  @override
  EndpointResult(){
    getInfo();
  }

  Future<void> getInfo() async {
    endPoint = await _storage.read(key: "host");
    apiKey = await _storage.read(key: "api_key");

    notifyListeners();
  }

  Future<void> setInfo(String? endpoint, String? apiKey) async {

    if (endpoint != null) {
      endpoint = endpoint;
      await _storage.write(key: "host", value: endpoint);
    }
    if (apiKey != null) {
      apiKey = apiKey;
      await _storage.write(key: "api_key", value: apiKey);
    }
  }
}