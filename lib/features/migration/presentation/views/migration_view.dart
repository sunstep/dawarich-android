import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/constants/constants.dart';
import 'package:dawarich/core/di/providers/migration_providers.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/migration/presentation/viewmodels/migration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
final class MigrationView extends ConsumerWidget {
  const MigrationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(migrationViewModelProvider);

    return vmAsync.when(
      loading: () => _ScaffoldShell(
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _ScaffoldShell(
        child: Center(child: Text(e.toString())),
      ),
      data: (vm) => _MigrationContent(vm: vm),
    );
  }
}

final class _MigrationContent extends StatefulWidget {
  final MigrationViewModel vm;

  const _MigrationContent({required this.vm});

  @override
  State<_MigrationContent> createState() => _MigrationContentState();
}

final class _MigrationContentState extends State<_MigrationContent> {
  bool _started = false;

  MigrationViewModel get vm => widget.vm;

  @override
  void initState() {
    super.initState();

    vm.addListener(_onVmChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_started) {
        return;
      }

      _started = true;

      await Future.delayed(kMigrationDelay);

      if (!mounted) {
        return;
      }

      await vm.startMigration(context);
    });
  }

  @override
  void dispose() {
    vm.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ScaffoldShell(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.sync,
                size: 96,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(height: 24),
              Text(
                'Updating Database',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Almost there—finalizing your update.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (vm.error != null)
                _ErrorCard(
                  errorMessage: vm.error!,
                  onRetry: () => vm.retryMigration(context),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please wait…',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ScaffoldShell extends StatelessWidget {
  final Widget child;

  const _ScaffoldShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).pageBackground,
        ),
        child: child,
      ),
    );
  }
}

/// A styled card to display migration errors with a retry button.
class _ErrorCard extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 32),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Migration Failed',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Retry Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
