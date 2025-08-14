

import 'package:dawarich/features/version_check/application/version_check_service.dart';
import 'package:flutter/material.dart';
import 'package:option_result/option_result.dart';
import 'package:pub_semver/pub_semver.dart';

final class VersionCheckViewModel extends ChangeNotifier {


  final VersionCheckService _versionCheckService;
  VersionCheckViewModel(this._versionCheckService);

  bool _isLoading = true;
  bool _isSupported = false;
  String? _errorMessage;

  String? _serverVersion;
  String? _requiredVersion;

  bool get isLoading => _isLoading;
  bool get isSupported => _isSupported;
  String? get errorMessage => _errorMessage;

  String? get serverVersion => _serverVersion;
  String? get requiredVersion => _requiredVersion;

  Future<void> initialize() async {
    try {
      setIsLoading(true);

      Result<(), String> serverSupportedResult = await _versionCheckService.isServerVersionSupported();

      _isSupported = serverSupportedResult.isOk();

      if (_isSupported) {
        _errorMessage = null; // clear any old message
      } else if (serverSupportedResult case Err(value: final String message)) {
        setErrorMessage(message);
      }

      final Version serverVersion = await _versionCheckService.getServerVersion();
      setServerVersion(serverVersion);
    } catch (e) {
      _errorMessage = 'Failed to check server version: $e';
    } finally {
      setIsLoading(false);
    }
  }

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setServerVersion(Version version) {
    _serverVersion = version.toString();
    notifyListeners();
  }

  void setRequiredVersion(Version version) {
    _requiredVersion = version.toString();
    notifyListeners();
  }

  Future<bool> retry() async {
    setIsLoading(true);
    setErrorMessage(null);

    try {
      final Version sv = await _versionCheckService.getServerVersion();
      setServerVersion(sv);

      final Result<void, String> r = await _versionCheckService.isServerVersionSupported();
      final ok = r.isOk();

      _isSupported = ok;
      if (!ok) {
        setErrorMessage(r.unwrapErr());
      } else {
        setErrorMessage(null);
      }
      return ok;
    } catch (e) {
      _isSupported = false;
      setErrorMessage('Failed to check server version: $e');
      return false;
    } finally {
      setIsLoading(false);
    }
  }
}