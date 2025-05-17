import 'package:dawarich/application/startup/dependency_injector.dart';
import 'package:dawarich/ui/models/local/connect_page_viewmodel.dart';
import 'package:dawarich/ui/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  ConnectPageState createState() => ConnectPageState();
}

class ConnectPageState extends State<ConnectPage> {
  final _hostFormKey = GlobalKey<FormState>();
  final _apiFormKey  = GlobalKey<FormState>();

  final _hostController = TextEditingController();
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  final _apiKeyController = TextEditingController();

  int _currentStep = 0;

  @override
  void dispose() {
    _hostController.dispose();
    // _emailController.dispose();
    // _passwordController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ConnectViewModel>(),
      child: Scaffold(
        body: _buildGradientBackground(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: _buildFormCard(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Consumer<ConnectViewModel>(builder: (ctx, vm, _) {
              return Stepper(
                physics: const ClampingScrollPhysics(),
                currentStep: _currentStep,
                onStepContinue: () => _nextStep(ctx, vm),
                onStepCancel: _currentStep > 0
                  ? () {
                    if (_currentStep == 1) {
                      vm.resetHostVerification();
                    }
                    setState(() => _currentStep--);
                  } : null,
                controlsBuilder: (ctx, details) => _buildControls(ctx, details),
                steps: [
                  _serverStep(ctx, vm),
                  _loginStep(ctx, vm),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<ConnectViewModel>(
      builder: (ctx, vm, _) {
        return Column(
          children: [
            // animated switcher to smooth the icon change
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CircleAvatar(
                key: ValueKey<bool>(vm.hostVerified),
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
      },
    );
  }

  Step _serverStep(BuildContext context, ConnectViewModel vm) {
    return Step(
      title: const Text('Server'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _hostFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _hostController,
                decoration: InputDecoration(
                  labelText: 'Host URL',
                  prefixIcon: const Icon(Icons.link),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
                keyboardType: TextInputType.url,
                validator: (v) =>
                (v != null && v.isNotEmpty) ? null : 'Please enter a host URL.',
              ),
              const SizedBox(height: 16),
              if (vm.errorMessage != null && _currentStep == 0) ...[
                Text(
                  vm.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Step _loginStep(BuildContext context, ConnectViewModel vm) {
    return Step(
      title: const Text('Login'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _apiFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: _buildApiKeyForm(context, vm)
        ),
      )
    );
  }

  Widget _buildApiKeyForm(BuildContext context, ConnectViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,  // makes it fill the width
      children: [
        TextFormField(
          controller: _apiKeyController,
          onChanged: (_) => vm.clearErrorMessage(),
          decoration: InputDecoration(
            labelText: 'API Key',
            prefixIcon: const Icon(Icons.vpn_key),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: IconButton(
              icon: Icon(vm.apiKeyVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => vm.setApiKeyVisibility(!vm.apiKeyVisible),
            ),
          ),
          obscureText: !vm.apiKeyVisible,
          validator: (v) => (v != null && v.isNotEmpty) ? null : 'Enter API key',
        ),
        if (vm.errorMessage != null && _currentStep == 1) ...[
          const SizedBox(height: 8),
          Text(
            vm.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Coming Soon'),
                content: const Text('Email/password login is not supported yet.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Use Email / Password'),
        ),
      ],
    );
  }

  // Widget _buildCredentialForm(BuildContext context, ConnectViewModel vm) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       TextFormField(
  //         controller: _emailController,
  //         decoration: InputDecoration(
  //           labelText: 'Email',
  //           prefixIcon: const Icon(Icons.email),
  //           filled: true,
  //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //         ),
  //         keyboardType: TextInputType.emailAddress,
  //         validator: (v) => (v != null && v.contains('@')) ? null : 'Enter a valid email',
  //       ),
  //       const SizedBox(height: 12),
  //       TextFormField(
  //         controller: _passwordController,
  //         obscureText: !vm.passwordVisible,
  //         decoration: InputDecoration(
  //           labelText: 'Password',
  //           prefixIcon: const Icon(Icons.lock),
  //           suffixIcon: IconButton(
  //             icon: Icon(vm.passwordVisible ? Icons.visibility : Icons.visibility_off),
  //             onPressed: () => vm.setPasswordVisibility(!vm.passwordVisible),
  //           ),
  //           filled: true,
  //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //         ),
  //         validator: (v) => (v != null && v.isNotEmpty) ? null : 'Enter your password',
  //       ),
  //       const SizedBox(height: 12),
  //       TextButton(
  //         onPressed: () => vm.setApiKeyPreference(true),
  //         child: const Text('Use API Key Instead'),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    final isLast = _currentStep == 1;
    final vm = Provider.of<ConnectViewModel>(context, listen: false);
    final busy = vm.isVerifyingHost || vm.isLoggingIn;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Back'),
            ),
          Expanded(
            child: ElevatedButton(
              onPressed: busy ? null : details.onStepContinue,
              child: busy
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
                  : Text(isLast ? 'Sign in' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _nextStep(BuildContext context, ConnectViewModel vm) async {
    if (_currentStep == 0) {
      if (!_hostFormKey.currentState!.validate()) {
        return;
      }
      final ok = await vm.testHost(_hostController.text.trim());

        if (ok) {
          setState(() => _currentStep = 1);
        }

    }
    else if (_currentStep == 1) {
      if (!_apiFormKey.currentState!.validate()) return;
      final ok = await vm.tryLoginApiKey(_apiKeyController.text.trim());
      if (ok && context.mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.map);
      }
    }
  }
}
