import 'package:dawarich/ui/models/local/connect_page_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServerStepWidget extends StatelessWidget {
  const ServerStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConnectViewModel>();
    return Form(
      key: vm.hostFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: vm.hostController,
              decoration: InputDecoration(
                labelText: 'Host URL',
                prefixIcon: const Icon(Icons.link),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
              keyboardType: TextInputType.url,
              validator: (v) =>
              (v != null && v.isNotEmpty) ? null : 'Please enter a host URL.',
            ),
            const SizedBox(height: 16),
            if (vm.errorMessage != null)
              Text(
                vm.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }
}

class LoginStepWidget extends StatelessWidget {
  const LoginStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConnectViewModel>();
    return Form(
      key: vm.apiFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: vm.apiKeyController,
              obscureText: !vm.apiKeyVisible,
              decoration: InputDecoration(
                labelText: 'API Key',
                prefixIcon: const Icon(Icons.vpn_key),
                filled: true,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: Icon(vm.apiKeyVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () => vm.setApiKeyVisibility(!vm.apiKeyVisible),
                ),
              ),
              validator: (v) =>
              (v != null && v.isNotEmpty) ? null : 'Enter API key',
            ),
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  vm.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Coming Soon'),
                  content: const Text(
                      'Email/password login is not supported yet.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    )
                  ],
                ),
              ),
              child: const Text('Use Email / Password'),
            ),
          ],
        ),
      ),
    );
  }
}
