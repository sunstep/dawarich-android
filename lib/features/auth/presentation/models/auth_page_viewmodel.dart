import 'package:dawarich/features/auth/application/services/connect_service.dart';
import 'package:dawarich/features/version_check/application/version_check_service.dart';
import 'package:flutter/material.dart';

final class AuthPageViewModel extends ChangeNotifier {

  final ConnectService _connectService;
  final VersionCheckService _versionCheckService;
  AuthPageViewModel(this._connectService, this._versionCheckService);

  // final GlobalKey _emailController = TextEditingController();
  // final GlobalKey _passwordController = TextEditingController();

  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  int _currentStep = 0;
  bool _isVerifyingHost = false;
  bool _isLoggingIn = false;
  bool _hostVerified = false;
  bool _apiKeyPreferred = true;
  bool _passwordVisible = false;
  bool _apiKeyVisible = false;
  String? _snackbarMessage;
  String? _errorMessage;

  // Public getters

  TextEditingController get hostController => _hostController;
  TextEditingController get apiKeyController => _apiKeyController;

  int get currentStep => _currentStep;
  bool get isVerifyingHost => _isVerifyingHost;
  bool get isLoggingIn => _isLoggingIn;
  bool get hostVerified => _hostVerified;
  bool get apiKeyPreferred => _apiKeyPreferred;
  bool get passwordVisible => _passwordVisible;
  bool get apiKeyVisible => _apiKeyVisible;
  String? get snackbarMessage => _snackbarMessage;
  String? get errorMessage => _errorMessage;

  /// Verifies connectivity to the given [host].
  Future<bool> testHost(String host) async {
    _setVerifyingHost(true);
    _setErrorMessage(null);

    final bool result = await _connectService.testHost(host.trim());

    _setVerifyingHost(false);
    if (result) {
      _setHostVerified(true);
      return true;
    }

    _setErrorMessage('Unable to reach the host. Please try again.');
    return false;
  }

  /// Call this when the user goes back to step 1
  void resetHostVerification() {
    _setHostVerified(false);
    clearErrorMessage();
  }

  /// Attempts API-key based authentication.
  Future<bool> tryLoginApiKey(String apiKey) async {
    _setLoggingIn(true);
    _setErrorMessage(null);

    final bool isValid = await _connectService.loginApiKey(apiKey.trim());
    _setLoggingIn(false);

    if (isValid) {
      clearErrorMessage();
      return true;
    }

    _setErrorMessage('Invalid API key. Please check and try again.');
    return false;
  }

  /// Attempts email/password based authentication.
  // Future<bool> tryLoginCredentials(String email, String password) async {
  //   _setLoggingIn(true);
  //   _setErrorMessage(null);
  //
  //   final bool success = await _connectService.loginWithCredentials(
  //     email.trim(), password,
  //   );
  //   _setLoggingIn(false);
  //
  //   if (success) return true;
  //
  //   _setErrorMessage('Invalid email or password.');
  //   return false;
  // }

  Future<bool> checkServerSupport() async {
    return await _versionCheckService.isServerVersionSupported();
  }

  void goToNextStep() {
    _currentStep++;
    notifyListeners();
  }

  void goToPreviousStep() {
    _currentStep--;
    clearErrorMessage();
    notifyListeners();
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  // Toggle API key vs credential login
  void setApiKeyPreference(bool useApiKey) {
    _apiKeyPreferred = useApiKey;
    notifyListeners();
  }

  // Toggle visibility of password
  void setPasswordVisibility(bool visible) {
    _passwordVisible = visible;
    notifyListeners();
  }

  // Toggle visibility of API key
  void setApiKeyVisibility(bool visible) {
    _apiKeyVisible = visible;
    notifyListeners();
  }

  /// Manually set a one-time snack message.
  void setSnackbarMessage(String message) {
    _snackbarMessage = message;
    notifyListeners();
  }

  /// Clears currently queued snack message.
  void clearSnackbarMessage() {
    _snackbarMessage = null;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Private setters with notification
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

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
