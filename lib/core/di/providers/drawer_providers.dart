
import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/shell/drawer/api_config_service.dart';
import 'package:dawarich/core/shell/drawer/drawer_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiConfigServiceProvider = FutureProvider<ApiConfigService>((ref) async {
  final logout = await ref.watch(apiConfigLogoutProvider.future);
  return ApiConfigService(logout);
});

final drawerViewModelProvider = FutureProvider<DrawerViewModel>((ref) async {
  final sessionBox = await ref.watch(sessionBoxProvider.future);
  final apiConfigService = await ref.watch(apiConfigServiceProvider.future);

  final vm = DrawerViewModel(sessionBox, apiConfigService);

  ref.onDispose(vm.dispose);
  return vm;
});