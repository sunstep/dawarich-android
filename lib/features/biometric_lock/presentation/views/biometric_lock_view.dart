import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/di/providers/settings_providers.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/biometric_lock/domain/app_lock_timestamp_tracker.dart';
import 'package:dawarich/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
final class BiometricLockView extends ConsumerStatefulWidget {
  const BiometricLockView({super.key});

  @override
  ConsumerState<BiometricLockView> createState() => _BiometricLockViewState();
}

class _BiometricLockViewState extends ConsumerState<BiometricLockView> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    final authenticate = ref.read(authenticateBiometricUseCaseProvider);
    final success = await authenticate();

    if (!mounted) return;

    if (success) {
      final repo = await ref.read(appSettingsRepositoryProvider.future);
      final userId = await ref.read(sessionUserIdProvider.future);
      if (userId != null) {
        await AppLockTimestampTracker.instance.onAuthenticated(repo, userId);
      }
      appRouter.replaceAll([const TimelineRoute()]);
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(gradient: theme.pageBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'App Locked',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Authenticate to continue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  if (_failed) ...[
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() => _failed = false);
                        _authenticate();
                      },
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Try Again'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}





