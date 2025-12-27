

import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/features/version_check/application/usecases/get_server_version_usecase.dart';
import 'package:dawarich/features/version_check/application/usecases/server_version_compatability_usecase.dart';
import 'package:flutter/material.dart';
import 'package:option_result/option_result.dart';
import 'package:pub_semver/pub_semver.dart';

final class VersionCheckViewModel extends ChangeNotifier {


  final ServerVersionCompatabilityUseCase _serverVersionCompatabilityChecker;
  final GetServerVersionUseCase _serverVersionGetter;

  VersionCheckViewModel(this._serverVersionCompatabilityChecker, this._serverVersionGetter);

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

      Result<(), Failure> serverSupportedResult = await _serverVersionCompatabilityChecker();

      _isSupported = serverSupportedResult.isOk();

      if (_isSupported) {
        _errorMessage = null; // clear any old message
      } else if (serverSupportedResult case Err(value: final String message)) {
        setErrorMessage(message);
      }

      final Result<Version, Failure> serverVersion = await _serverVersionGetter();

      setServerVersion(serverVersion.unwrap());
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
      final Result<Version, Failure> sv = await _serverVersionGetter();
      setServerVersion(sv.unwrap());

      final Result<(), Failure> r = await _serverVersionCompatabilityChecker();
      final ok = r.isOk();

      _isSupported = ok;
      if (!ok) {
        setErrorMessage(r.unwrapErr().message);
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