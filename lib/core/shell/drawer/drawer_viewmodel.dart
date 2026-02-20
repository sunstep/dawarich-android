import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/presentation/safe_change_notifier.dart';
import 'package:dawarich/core/shell/drawer/api_config_service.dart';
import 'package:dawarich_android_user_module/dawarich_android_user_module.dart';
import 'package:flutter/foundation.dart';

class DrawerViewModel with ChangeNotifier, SafeChangeNotifier {
  final DawarichAndroidUserModule<User> _sessionService;
  final ApiConfigService _apiConfigService;

  DrawerViewModel(this._sessionService, this._apiConfigService);

  Future<void> logout() async {
    await _sessionService.logout();
    await _apiConfigService.clearApiConfig();
  }
}
