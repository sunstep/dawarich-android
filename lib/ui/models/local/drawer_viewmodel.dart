import 'package:dawarich/application/services/api_config_service.dart';
import 'package:flutter/foundation.dart';

class DrawerViewModel with ChangeNotifier {

  final ApiConfigService apiConfigService;

  DrawerViewModel(this.apiConfigService);

  Future<void> logout() async {
    await apiConfigService.clearApiConfig();
  }
}