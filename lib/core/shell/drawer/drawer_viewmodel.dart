import 'package:dawarich/core/shell/drawer/api_config_service.dart';
import 'package:dawarich/core/session/user_session_service.dart';
import 'package:flutter/foundation.dart';
import 'package:user_session_manager/user_session_manager.dart';

class DrawerViewModel with ChangeNotifier {
  final UserSessionManager<int> _sessionService;
  final ApiConfigService _apiConfigService;

  DrawerViewModel(this._sessionService, this._apiConfigService);

  Future<void> logout() async {
    await _sessionService.logout();
    await _apiConfigService.clearApiConfig();
  }
}
