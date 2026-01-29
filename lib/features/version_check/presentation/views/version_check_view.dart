import 'package:auto_route/annotations.dart';
import 'package:dawarich/core/di/providers/version_check_providers.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/version_check/presentation/viewmodels/version_check_viewmodel.dart';
import 'package:dawarich/main.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
final class VersionCheckView extends ConsumerStatefulWidget {

  const VersionCheckView({super.key});

  @override
  ConsumerState<VersionCheckView> createState() => _VersionCheckViewState();
}

final class _VersionCheckViewState extends ConsumerState<VersionCheckView> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = await ref.read(versionCheckViewModelProvider.future);
      if (!mounted) return;
      await vm.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vmAsync = ref.watch(versionCheckViewModelProvider);

    return vmAsync.when(
      loading: () => Container(
        decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Container(
        decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: Text(e.toString())),
        ),
      ),
      data: (vm) => _VersionCheckContent(
        vm: vm,
        onRetrySuccess: () {
          appRouter.replaceAll([const TimelineRoute()]);
        },
      ),
    );
  }
}

final class _VersionCheckContent extends StatelessWidget {

  final VersionCheckViewModel vm;
  final VoidCallback onRetrySuccess;

  const _VersionCheckContent({
    required this.vm,
    required this.onRetrySuccess,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).pageBackground,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppbar(
          title: "Update Required",
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.system_update, size: 64, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 24),
                    Text(
                      "Update Needed",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(vm.errorMessage ??
                        "Verifying compatibility with the server. Please wait...",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (vm.isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton.icon(
                        onPressed: () async {
                          final bool success = await vm.retry();

                          if (success) {
                            appRouter.replaceAll([const TimelineRoute()]);
                          }

                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}