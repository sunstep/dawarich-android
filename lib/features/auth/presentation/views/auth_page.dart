import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/di/providers/auth_providers.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/auth/presentation/viewmodels/auth_page_viewmodel.dart';
import 'package:dawarich/features/auth/presentation/widgets/connect_steps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

@RoutePage()
final class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(authPageViewModelProvider);
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
      data: (vm) => provider.ChangeNotifierProvider<AuthPageViewModel>.value(
        value: vm,
        child: _AuthScaffold(vm: vm),
      ),
    );
  }
}

final class _AuthScaffold extends StatelessWidget {
  final AuthPageViewModel vm;

  const _AuthScaffold({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: _AuthFormCard(vm: vm),
          ),
        ),
      ),
    );
  }
}

final class _AuthFormCard extends StatefulWidget {
  final AuthPageViewModel vm;

  const _AuthFormCard({required this.vm});

  @override
  State<_AuthFormCard> createState() => _AuthFormCardState();
}

class _AuthFormCardState extends State<_AuthFormCard> {
  final _hostFormKey = GlobalKey<FormState>();
  final _apiFormKey = GlobalKey<FormState>();

  AuthPageViewModel get vm => widget.vm;

  @override
  void initState() {
    super.initState();

    vm.addListener(_onVmChanged);
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
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConnectHeader(vm: vm),
            const SizedBox(height: 24),
            Stepper(
              physics: const ClampingScrollPhysics(),
              currentStep: vm.currentStep,
              onStepContinue: () => _handleContinue(context, vm),
              onStepCancel: vm.currentStep > 0 ? () => vm.goToPreviousStep() : null,
              controlsBuilder: (ctx, details) => _buildControls(ctx, details, vm),
              steps: [
                Step(
                  title: const Text('Server'),
                  isActive: vm.currentStep >= 0,
                  state: vm.currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: ServerStepWidget(formKey: _hostFormKey),
                ),
                Step(
                  title: const Text('Login'),
                  isActive: vm.currentStep >= 1,
                  state: vm.currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: LoginStepWidget(formKey: _apiFormKey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue(BuildContext context, AuthPageViewModel vm) async {
    if (vm.currentStep == 0) {
      if (!(_hostFormKey.currentState?.validate() ?? false)) {
        return;
      }

      final ok = await vm.testHost(vm.hostController.text.trim());

      if (ok) {
        vm.goToNextStep();
      }

      return;
    }

    if (!(_apiFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final ok = await vm.tryLoginApiKey(vm.apiKeyController.text.trim());

    if (!ok) {
      return;
    }

    final bool isServerSupported = await vm.checkServerSupport();

    if (kDebugMode || isServerSupported) {
      if (context.mounted) {
        context.router.root.replaceAll([const TimelineRoute()]);
      }
      return;
    }

    if (context.mounted) {
      context.router.root.replaceAll([const VersionCheckRoute()]);
    }
  }

  Widget _buildControls(BuildContext context, ControlsDetails d, AuthPageViewModel vm) {
    final busy = vm.isVerifyingHost || vm.isLoggingIn;
    final isLast = vm.currentStep == 1;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (vm.currentStep > 0)
            TextButton(onPressed: d.onStepCancel, child: const Text('Back')),
          const Spacer(),
          ElevatedButton(
            onPressed: busy ? null : d.onStepContinue,
            child: busy
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : Text(isLast ? 'Sign in' : 'Next'),
          ),
        ],
      ),
    );
  }
}

final class _ConnectHeader extends StatelessWidget {
  final AuthPageViewModel vm;

  const _ConnectHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: CircleAvatar(
            key: ValueKey(vm.hostVerified),
            backgroundColor: Theme.of(context).colorScheme.primary,
            radius: 36,
            child: Icon(
              vm.hostVerified ? Icons.cloud_done : Icons.cloud,
              size: 36,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connect to Dawarich',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}