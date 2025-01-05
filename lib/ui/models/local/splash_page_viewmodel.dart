import 'package:dawarich/application/services/api_config_service.dart';
import 'package:flutter/foundation.dart';

class SplashViewModel with ChangeNotifier {

  final ApiConfigService apiConfigService;
  SplashViewModel(this.apiConfigService);

  Future<bool> checkLoginStatusAsync() async {

    await apiConfigService.initialize();
    return apiConfigService.isConfigured();
  }


}