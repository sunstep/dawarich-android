import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/core/presentation/safe_change_notifier.dart';
import 'package:dawarich/features/auth/application/usecases/login_with_api_key_usecase.dart';
import 'package:dawarich/features/auth/application/usecases/test_host_connection_usecase.dart';
import 'package:dawarich/features/auth/domain/models/auth_qr_payload.dart';
import 'package:dawarich/features/version_check/application/usecases/refresh_server_compatibility_usecase.dart';
import 'package:flutter/material.dart';
import 'package:option_result/option_result.dart';

final class AuthPageViewModel extends ChangeNotifier with SafeChangeNotifier {

  final RefreshServerCompatibilityUseCase _refreshServerCompatibility;
  final TestHostConnectionUseCase _testHostConnectionUseCase;
  final LoginWithApiKeyUseCase _loginWithApiKeyUseCase;

  AuthPageViewModel(
    this._refreshServerCompatibility,
    this._testHostConnectionUseCase,
    this._loginWithApiKeyUseCase,
  );

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

  Future<void> initFromConfig(IApiConfigManager cfg) async {
    final apiConfig = cfg.apiConfig;

    final host = apiConfig?.host ?? '';
    final hasHost = apiConfig != null;

    _hostController.text = host;
    _currentStep = hasHost ? 1 : 0;

    _hostVerified = false;

    safeNotifyListeners();
  }

  void _onHostChanged() {
    if (_hostVerified) {
      _hostVerified = false;
      safeNotifyListeners();
    }
  }

  /// Verifies connectivity to the given [host].
  /// On success: normalizes the host (adds protocol if needed), updates the controller,
  /// marks host as verified, and returns true.
  /// On failure: sets a human-friendly error message and returns false.
  Future<bool> testHost(String host) async {
    _setVerifyingHost(true);
    _setErrorMessage(null);

    try {
      final res = await _testHostConnectionUseCase(host);

      if (res case Ok(value: final String normalizedHost)) {
        _hostController.text = normalizedHost;
        _setHostVerified(true);
        return true;
      }

      final failure = res.unwrapErr();
      _setHostVerified(false);
      _setErrorMessage(
        failure.code == 'HOST_EMPTY'
            ? 'Please enter a server address.'
            : 'Unable to reach the server. Please check the address and try again.',
      );
      return false;
    } finally {
      _setVerifyingHost(false);
    }
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

    try {
      final host = _hostController.text.trim();

      if (!_hostVerified || host.isEmpty) {
        _setErrorMessage('Please verify the server first.');
        return false;
      }

      final ok = await _loginWithApiKeyUseCase(
        host: host,
        apiKey: apiKey.trim(),
      );

      if (!ok) {
        _setErrorMessage('Invalid API key. Please check and try again.');
        return false;
      }

      clearErrorMessage();
      return true;
    } finally {
      _setLoggingIn(false);
    }
  }

  Future<void> tryQrLogin(
      String qrResult, {
        required VoidCallback onNavigateToTimeline,
        required void Function(String) onShowError,
      }) async {
    _setErrorMessage(null);
    _setLoggingIn(true);
    _setVerifyingHost(true);

    try {
      final payload = AuthQrPayload.fromJsonString(qrResult.trim());

      setHost(payload.serverUrl);
      setApiKey(payload.apiKey);

      final okLogin = await _loginWithApiKeyUseCase(apiKey: payload.apiKey, host: payload.serverUrl);
      if (!okLogin) {
        final hostRes = await _testHostConnectionUseCase(payload.serverUrl);
        if (hostRes.isErr()) {
          onShowError('Server unreachable or invalid.');
        } else {
          onShowError('Invalid API key.');
        }
        return;
      }

      await refreshServerCompatibility();
      onNavigateToTimeline();
    } on FormatException {
      onShowError('The scanned QR code is invalid. Please try again.');
    } catch (_) {
      onShowError('Login failed. Please try again.');
    } finally {
      _setVerifyingHost(false);
      _setLoggingIn(false);
    }
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

  Future<bool> refreshServerCompatibility() async {
    final Result<(), Failure> supportResult = await _refreshServerCompatibility();
    return supportResult.isOk();
  }

  void goToNextStep() {
    _currentStep++;
    safeNotifyListeners();
  }

  void goToPreviousStep() {
    _currentStep--;
    clearErrorMessage();
    safeNotifyListeners();
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    safeNotifyListeners();
  }

  // Toggle API key vs credential login
  void setApiKeyPreference(bool useApiKey) {
    _apiKeyPreferred = useApiKey;
    safeNotifyListeners();
  }

  void setHost(String host) {
    _hostController.text = host;
    safeNotifyListeners();
  }

  void setApiKey(String apiKey) {
    _apiKeyController.text = apiKey;
    safeNotifyListeners();
  }

  // Toggle visibility of password
  void setPasswordVisibility(bool visible) {
    _passwordVisible = visible;
    safeNotifyListeners();
  }

  // Toggle visibility of API key
  void setApiKeyVisibility(bool visible) {
    _apiKeyVisible = visible;
    safeNotifyListeners();
  }

  /// Manually set a one-time snack message.
  void setSnackbarMessage(String message) {
    _snackbarMessage = message;
    safeNotifyListeners();
  }

  /// Clears currently queued snack message.
  void clearSnackbarMessage() {
    _snackbarMessage = null;
    safeNotifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    safeNotifyListeners();
  }

  // Private setters with notification
  void _setVerifyingHost(bool value) {
    _isVerifyingHost = value;
    safeNotifyListeners();
  }

  void _setLoggingIn(bool value) {
    _isLoggingIn = value;
    safeNotifyListeners();
  }

  void _setHostVerified(bool value) {
    _hostVerified = value;
    safeNotifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    safeNotifyListeners();
  }

  @override
  void dispose() {
    _hostController.removeListener(_onHostChanged);
    _hostController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }
}
