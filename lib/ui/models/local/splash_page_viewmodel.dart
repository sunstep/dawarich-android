import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/user_session_service.dart';
import 'package:flutter/foundation.dart';

class SplashViewModel with ChangeNotifier {

  final UserSessionService _sessionService;
  final ApiConfigService _apiService;

  SplashViewModel(this._sessionService, this._apiService);

  Future<bool> checkLoginStatusAsync() async {

    await _sessionService.getCurrentUserId();
    if (_sessionService.isLoggedIn) {
      await _apiService.initialize();
    }

    return _sessionService.isLoggedIn;
  }


}