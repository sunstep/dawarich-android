import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/shell/drawer/api_config_service.dart';
import 'package:flutter/foundation.dart';
import 'package:session_box/session_box.dart';

class DrawerViewModel with ChangeNotifier {
  final SessionBox<User> _sessionService;
  final ApiConfigService _apiConfigService;

  DrawerViewModel(this._sessionService, this._apiConfigService);

  Future<void> logout() async {
    await _sessionService.logout();
    await _apiConfigService.clearApiConfig();
  }
}
