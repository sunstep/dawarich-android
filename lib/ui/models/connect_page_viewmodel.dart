import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/connect_service.dart';
import 'package:flutter/material.dart';

class ConnectViewModel with ChangeNotifier {

  final ApiConfigService _apiConfigService;
  final ConnectService _connectService;
  ConnectViewModel(this._apiConfigService, this._connectService);

  bool _isVerifyingHost = false;
  bool _isLoggingIn = false;
  bool _hostVerified = false;
  bool _apiKeyPreferred = true;
  bool _passwordVisible = false;
  bool _apiKeyVisible = false;
  String? _snackbarMessage;
  String? _errorMessage;

  bool get isVerifyingHost => _isVerifyingHost;
  bool get isLoggingIn => _isLoggingIn;
  bool get hostVerified => _hostVerified;
  bool get apiKeyPreferred => _apiKeyPreferred;
  bool get passwordVisible => _passwordVisible;
  bool get apiKeyVisible => _apiKeyVisible;
  String? get snackbarMessage => _snackbarMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> testHost(String host) async {

    _setVerifyingHost(true);
    _setErrorMessage(null);

    final bool result = await _connectService.testHost(host);

    _setVerifyingHost(false);

    if (result) {
      _setHostVerified(true);
      return true;
    } else {
      _setErrorMessage("Unable to reach the host. Please try again.");
      return false;
    }
  }

  Future<bool> logIn(String email, String password) async {
    _setLoggingIn(true);
    _setErrorMessage(null);

    await Future.delayed(const Duration(seconds: 2));
    final result = email == 'test@example.com' && password == 'password123'; // Mock logic

    _setLoggingIn(false);

    if (result) {
      return true;
    } else {
      _setErrorMessage("Invalid email or password.");
      return false;
    }
  }

  Future<bool> tryLoginApiKey(String apiKey) async {

    _setLoggingIn(true);
    _setErrorMessage(null);

    apiKey = apiKey.trim();

    bool isValid = await _connectService.tryApiKey(apiKey);

    if (isValid) {
      await _apiConfigService.storeApiConfig();
      _setLoggingIn(true);
      return true;
    }

    _setLoggingIn(false);
    return false;
  }

  void _setVerifyingHost(bool value) {
    _isVerifyingHost = value;
    notifyListeners();
  }

  void _setLoggingIn(bool value) {
    _isLoggingIn = value;
    notifyListeners();
  }

  void _setHostVerified(bool value) {
    _hostVerified = value;
    notifyListeners();
  }

  void setApiKeyPreference(bool trueOrFalse) {
    _apiKeyPreferred = trueOrFalse;
    notifyListeners();
  }

  void setPasswordVisibility(bool trueOrFalse) {
    _passwordVisible = trueOrFalse;
    notifyListeners();
  }

  void setApiKeyVisibility(bool trueOrFalse) {
    _apiKeyVisible = trueOrFalse;
    notifyListeners();
  }

  void setSnackbarMessage(String message) {
    _snackbarMessage = message;
    notifyListeners();
  }

  void clearSnackbarMessage() {
    _snackbarMessage = null;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
