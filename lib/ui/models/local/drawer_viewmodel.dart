import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/user_session_service.dart';
import 'package:flutter/foundation.dart';

class DrawerViewModel with ChangeNotifier {
  final UserSessionService _sessionService;
  final ApiConfigService _apiConfigService;

  DrawerViewModel(this._sessionService, this._apiConfigService);

  Future<void> logout() async {
    await _sessionService.clearCurrentUserId();
    await _apiConfigService.clearApiConfig();
  }
}
