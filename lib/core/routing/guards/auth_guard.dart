import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:session_box/session_box.dart';

/// A route guard that ensures the user is authenticated.
/// If not authenticated, redirects to the auth page.
/// When authenticated, stores the User in authenticatedUserProvider.
final class AuthGuard extends AutoRouteGuard {
  final ProviderContainer _container;

  AuthGuard(this._container);

  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      final SessionBox<User> sessionBox = await _container.read(sessionBoxProvider.future);
      final User? user = await sessionBox.getUser();

      if (user != null) {
        _container.read(authenticatedUserProvider.notifier).setUser(user);
        resolver.next(true);
      } else {
        if (kDebugMode) {
          debugPrint('[AuthGuard] User not authenticated, redirecting to auth...');
        }
        _container.read(authenticatedUserProvider.notifier).setUser(null);
        resolver.redirectUntil(const AuthRoute());
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[AuthGuard] Error checking auth: $e\n$s');
      }
      _container.read(authenticatedUserProvider.notifier).setUser(null);
      resolver.redirectUntil(const AuthRoute());
    }
  }
}
