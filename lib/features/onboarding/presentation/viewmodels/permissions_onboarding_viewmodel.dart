import 'package:dawarich/core/presentation/safe_change_notifier.dart';
import 'package:dawarich/features/onboarding/application/usecases/check_onboarding_permissions_usecase.dart';
import 'package:dawarich/features/onboarding/application/usecases/request_onboarding_permission_usecase.dart';
import 'package:dawarich/features/onboarding/domain/permission_item.dart';
import 'package:flutter/foundation.dart';

final class PermissionsOnboardingViewModel extends ChangeNotifier
    with SafeChangeNotifier {
  final CheckOnboardingPermissionsUseCase _checkPermissions;
  final RequestOnboardingPermissionUseCase _requestPermission;

  PermissionsOnboardingViewModel(this._checkPermissions, this._requestPermission);

  List<PermissionItem> _permissions = [];
  bool _isLoading = true;
  bool _isRequesting = false;

  List<PermissionItem> get permissions => _permissions;
  bool get isLoading => _isLoading;
  bool get isRequesting => _isRequesting;

  bool get allGranted => _permissions.isNotEmpty && _permissions.every((p) => p.granted);
  int get grantedCount => _permissions.where((p) => p.granted).length;

  Future<void> initialize() async {
    _isLoading = true;
    safeNotifyListeners();

    _permissions = await _checkPermissions();

    _isLoading = false;
    safeNotifyListeners();
  }

  /// Refreshes the status of all permissions (e.g. after returning from
  /// system settings or app resume).
  Future<void> refreshPermissions() async {
    _permissions = await _checkPermissions();
    safeNotifyListeners();
  }

  /// Requests the permission at [index] and refreshes all statuses afterwards.
  Future<void> requestPermission(int index) async {
    if (_isRequesting) return;
    if (index < 0 || index >= _permissions.length) return;

    final item = _permissions[index];
    if (item.granted) return;

    _isRequesting = true;
    safeNotifyListeners();

    try {
      await _requestPermission(item.id);
      // Always re-check all permissions after a request, because granting
      // one may affect another (e.g. location "always" implies "when in use").
      _permissions = await _checkPermissions();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PermissionsOnboarding] Error requesting ${item.id}: $e');
      }
    } finally {
      _isRequesting = false;
      safeNotifyListeners();
    }
  }
}

