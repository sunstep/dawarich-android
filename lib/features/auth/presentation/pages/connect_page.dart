import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/features/auth/presentation/models/connect_page_viewmodel.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/auth/presentation/widgets/connect_steps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<ConnectViewModel>(),
      child: Container(
        decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: _ConnectFormCard(),
            ),
          ),
        ),
      ),
    );
  }
}

final class _ConnectFormCard extends StatefulWidget {
  const _ConnectFormCard();

  @override
  State<_ConnectFormCard> createState() => _ConnectFormCardState();
}

class _ConnectFormCardState extends State<_ConnectFormCard> {
  final _hostFormKey = GlobalKey<FormState>();
  final _apiFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ConnectViewModel vm = context.watch<ConnectViewModel>();
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ConnectHeader(),
            const SizedBox(height: 24),
            Stepper(
              physics: const ClampingScrollPhysics(),
              currentStep: vm.currentStep,
              onStepContinue: () => _handleContinue(context, vm),
              onStepCancel:
                  vm.currentStep > 0 ? () => vm.goToPreviousStep() : null,
              controlsBuilder: (ctx, details) =>
                  _buildControls(ctx, details, vm),
              steps: [
                Step(
                  title: const Text('Server'),
                  isActive: vm.currentStep >= 0,
                  state: vm.currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                  content: ServerStepWidget(
                    formKey: _hostFormKey,
                  ),
                ),
                Step(
                  title: const Text('Login'),
                  isActive: vm.currentStep >= 1,
                  state: vm.currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                  content: LoginStepWidget(formKey: _apiFormKey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// and re-connects your real logic.
  Future<void> _handleContinue(
      BuildContext context, ConnectViewModel vm) async {
    final navigator = Navigator.of(context);

    if (vm.currentStep == 0) {
      if (!(_hostFormKey.currentState?.validate() ?? false)) {
        return;
      }

      final ok = await vm.testHost(vm.hostController.text.trim());

      if (ok) {
        vm.goToNextStep();
      }
    } else {
      if (!(_apiFormKey.currentState?.validate() ?? false)) {
        return;
      }

      final ok = await vm.tryLoginApiKey(vm.apiKeyController.text.trim());

      if (ok) {
        // use the pre–captured navigator
        navigator.pushReplacementNamed(AppRouter.map);
      }
    }
  }

  Widget _buildControls(
      BuildContext context, ControlsDetails d, ConnectViewModel vm) {
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
  const _ConnectHeader();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConnectViewModel>();
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
