import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/presentation/safe_change_notifier.dart';
import 'package:dawarich/core/shell/drawer/api_config_service.dart';
import 'package:dawarich_android_user_module/dawarich_android_user_module.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerViewModel with ChangeNotifier, SafeChangeNotifier {

  final Ref _ref;
  final DawarichAndroidUserModule<User> _sessionService;
  final ApiConfigService _apiConfigService;

  DrawerViewModel(this._ref, this._sessionService, this._apiConfigService);

  Future<void> logout() async {
    await _sessionService.logout();
    await _apiConfigService.clearApiConfig();

    _ref.read(authenticatedUserProvider.notifier).setUser(null);

    _ref.invalidate(authenticatedUserProvider);
    _ref.invalidate(currentUserProvider);
    _ref.invalidate(currentUserIdProvider);

    _ref.invalidate(sessionUserProvider);
    _ref.invalidate(sessionUserIdProvider);

    _ref.invalidate(sessionBoxProvider);

  }
}
