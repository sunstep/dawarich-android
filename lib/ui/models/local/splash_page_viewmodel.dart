import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/user_session_service.dart';
import 'package:dawarich/data/drift/database/sqlite_client.dart';
import 'package:flutter/foundation.dart';

final class SplashViewModel with ChangeNotifier {

  final UserSessionService _sessionService;
  final ApiConfigService _apiService;
  final SQLiteClient _sqLiteClient;

  SplashViewModel(this._sessionService, this._apiService, this._sqLiteClient);

  Future<bool> needsMigration() async {
    final version = await _sqLiteClient.getUserVersion();
    await _sqLiteClient.close();
    return version < 2;
  }

  Future<bool> checkLoginStatusAsync() async {

    final int userId = await _sessionService.getCurrentUserId();

    return userId > 0;
  }


}