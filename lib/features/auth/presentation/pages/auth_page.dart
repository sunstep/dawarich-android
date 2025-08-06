import 'package:auto_route/annotations.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/features/auth/presentation/models/auth_page_viewmodel.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/auth/presentation/widgets/connect_steps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
final class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<AuthPageViewModel>(),
      child: Container(
        decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: _AuthFormCard(),
            ),
          ),
        ),
      ),
    );
  }
}

final class _AuthFormCard extends StatefulWidget {
  const _AuthFormCard();

  @override
  State<_AuthFormCard> createState() => _AuthFormCardState();
}

class _AuthFormCardState extends State<_AuthFormCard> {
  final _hostFormKey = GlobalKey<FormState>();
  final _apiFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthPageViewModel vm = context.watch<AuthPageViewModel>();
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

  Future<void> _handleContinue(
      BuildContext context, AuthPageViewModel vm) async {
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

        final bool isServerSupported = await vm.checkServerSupport();

        if (isServerSupported) {
          navigator.pushReplacementNamed(AppRouter.timeline);
        } else {
          navigator.pushReplacementNamed(AppRouter.versionCheck);
        }



      }
    }
  }

  Widget _buildControls(
      BuildContext context, ControlsDetails d, AuthPageViewModel vm) {
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
    final vm = context.watch<AuthPageViewModel>();
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
