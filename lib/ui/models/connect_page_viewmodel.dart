import 'package:dawarich/application/services/api_config_service.dart';
import 'package:flutter/material.dart';


class ConnectViewModel with ChangeNotifier {

  final ApiConfigService _apiConfigService;

  bool _isValidating = false;
  String? _credentialsError;

  bool get isValidating => _isValidating;
  String? get credentialsError => _credentialsError;

  Function? _navigatorFunction;

  ConnectViewModel(this._apiConfigService);

  Future<void> connect(String host, String apiKey) async {

    _setValidating(true);
    _credentialsError = null;

    host.trim();
    apiKey.trim();

    bool isValid = await _apiConfigService.testConnection(host, apiKey);

    if (isValid && _navigatorFunction != null) {
        _navigatorFunction!();
    } else {
      setCredentialsError('Invalid host or API key');
    }

    _setValidating(false);

  }

  String? validateInputs(String? input) {
    if (input == null || input.isEmpty) {
      return "This field is required";
    }

    return null;
  }


  void setNavigatorFunction(Function function){
    _navigatorFunction = function;
  }

  void _setValidating(bool isLoading) {
    _isValidating = isLoading;
    notifyListeners();
  }

  void setCredentialsError(String error) {
    _credentialsError = error;
    notifyListeners();
  }

  void clearErrors() {
    _credentialsError = null;
    notifyListeners();
  }
}