import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/startup/startup_service.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _hasStartedBoot = false;
  bool _hasRetriedAfterTimeout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBoot();
    });
  }

  Future<void> _startBoot() async {
    if (_hasStartedBoot) return;
    _hasStartedBoot = true;

    if (kDebugMode) {
      debugPrint('[SplashPage] Starting boot...');
    }

    try {
      // Add timeout to prevent hanging forever on boot failure
      await ref.read(coreProvider.future).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('[SplashPage] Core provider timed out');
          }
          throw TimeoutException('Core provider initialization timed out');
        },
      );

      if (!mounted) return;

      // Get the container from the ProviderScope
      final container = ProviderScope.containerOf(context);
      await StartupService.initializeAppFromContainer(container);

      if (kDebugMode) {
        debugPrint('[SplashPage] Boot completed.');
      }
    } on TimeoutException {
      // On hot restart, SQLite isolate may be stale. Invalidate and retry once.
      if (!_hasRetriedAfterTimeout) {
        _hasRetriedAfterTimeout = true;
        if (kDebugMode) {
          debugPrint('[SplashPage] Timeout - invalidating providers and retrying...');
        }

        // Invalidate core providers to force recreation
        ref.invalidate(coreProvider);

        // Reset flag and retry
        _hasStartedBoot = false;
        await Future.delayed(const Duration(milliseconds: 500));
        await _startBoot();
        return;
      }

      if (kDebugMode) {
        debugPrint('[SplashPage] Second timeout - navigating to auth');
      }
      appRouter.replaceAll([const AuthRoute()]);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[SplashPage] Error during boot: $e\n$st');
      }
      // On boot failure, navigate to auth so user isn't stuck on splash
      appRouter.replaceAll([const AuthRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }


}