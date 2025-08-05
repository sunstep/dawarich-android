

import 'package:dawarich/features/version_check/application/version_check_service.dart';
import 'package:flutter/material.dart';
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

      _isSupported = await _versionCheckService.isServerVersionSupported();
      final Version serverVersion = await _versionCheckService.getServerVersion();
      setServerVersion(serverVersion);
      setRequiredVersion(Version(0, 30, 6));
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

  Future<void> retry() async {

  }
}