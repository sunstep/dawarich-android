import 'package:dawarich/application/services/api_config_service.dart';
import 'package:flutter/cupertino.dart';

class SplashViewModel with ChangeNotifier {

  final ApiConfigService apiConfigService;
  Function(bool isConnected)? _navigate;

  SplashViewModel(this.apiConfigService);

  Future<void> initialize() async {

    await apiConfigService.initialize();
    bool isLoggedIn = apiConfigService.isConfigured();

    if (_navigate != null) {
      _navigate!(isLoggedIn);
    }

  }

  void setNavigationMethod(Function(bool isConnected) function) {
    _navigate = function;
  }

}