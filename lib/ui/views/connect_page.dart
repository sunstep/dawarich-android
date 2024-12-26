import 'package:dawarich/application/dependency_injection/service_locator.dart';
import 'package:dawarich/ui/models/connect_page_viewmodel.dart';
import 'package:dawarich/ui/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:provider/provider.dart';

class ConnectPage extends StatelessWidget {

  ConnectPage({super.key});

  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Widget> _hostFormContent(BuildContext context, ConnectViewModel viewModel) {
    return [
      TextFormField(
        controller: _hostController,
        decoration: const InputDecoration(
          labelText: 'Host',
        ).applyDefaults(Theme.of(context).inputDecorationTheme),
        keyboardType: TextInputType.url,
        validator: (value) => value != null && value.isNotEmpty
            ? null
            : 'Please enter a valid host URL.',
        autovalidateMode: AutovalidateMode.onUserInteraction,
        cursorColor: Theme.of(context).primaryColor
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        style: Theme.of(context).elevatedButtonTheme.style,
        onPressed: viewModel.isVerifyingHost
          ? null
          : () async {
            final messenger = ScaffoldMessenger.of(context);

            if (_formKey.currentState!.validate()) {
              final success = await viewModel.verifyHost(_hostController.text);
              if (success) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Successfully connected to Dawarich!')),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(content: Text(viewModel.errorMessage ?? 'Host verification failed.')),
                );
              }
            }
          },
        child: viewModel.isVerifyingHost
          ? Padding(
            padding: const EdgeInsets.all(8.0), // Add some space around the indicator
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          )
          : Text(
            'Connect',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ),
    ];
  }

  List<Widget> _loginFormContent(BuildContext context, ConnectViewModel viewModel) {

    final FocusNode emailFocusNode = FocusNode();
    AutovalidateMode emailAutoValidateMode = AutovalidateMode.disabled;

    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus) {
        emailAutoValidateMode = AutovalidateMode.onUserInteraction;
      }
    });

    return [
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
        ).applyDefaults(Theme.of(context).inputDecorationTheme),
        cursorColor: Theme.of(context).textTheme.bodySmall!.color,
        keyboardType: TextInputType.emailAddress,
        validator: (value) => value != null && value.contains('@')
            ? null
            : 'Please enter a valid email address.',
        autovalidateMode: emailAutoValidateMode,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
              viewModel.passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
            onPressed: () => {
              viewModel.setPasswordVisibility(!viewModel.passwordVisible)
            },
          )
        ).applyDefaults(Theme.of(context).inputDecorationTheme),
        cursorColor: Theme.of(context).textTheme.bodySmall!.color,
        obscureText: !viewModel.passwordVisible,
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        style: Theme.of(context).elevatedButtonTheme.style,
        onPressed: null,
        child: viewModel.isLoggingIn
            ? Padding(
          padding: const EdgeInsets.all(8.0), // Add some space around the indicator
          child: SizedBox(
            height: 18, // Control the size of the spinner
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        )
            : Text(
          'Login',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      TextButton(
        onPressed: () => {
          viewModel.setApiKeyPreference(true)
        },
        child: Text(
            "Login with API key",
            style: Theme.of(context).textTheme.bodySmall,
        )
      )
    ];
  }

  List<Widget> _apiKeyLoginFormContent(BuildContext context, ConnectViewModel viewModel) {
    return [
      TextFormField(
        controller: _apiKeyController,
        decoration: InputDecoration(
          labelText: 'Api Key',
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.apiKeyVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
              onPressed: () => {
                viewModel.setApiKeyVisibility(!viewModel.apiKeyVisible)
              },
            )
        ).applyDefaults(Theme.of(context).inputDecorationTheme),
        cursorColor: Theme.of(context).textTheme.bodySmall!.color,
        obscureText: !viewModel.apiKeyVisible,
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        style: Theme.of(context).elevatedButtonTheme.style,
        onPressed: viewModel.isLoggingIn
          ? null :
          () async {
            if (_formKey.currentState!.validate()) {

              final success = await viewModel.tryLoginApiKey(
                _apiKeyController.text
              );

              if (context.mounted && success) {
                Navigator.pushReplacementNamed(context, AppRouter.map);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(viewModel.errorMessage ?? 'Login failed.')),
                );
              }
            }
          },
        child: viewModel.isLoggingIn
            ? Padding(
          padding: const EdgeInsets.all(8.0), // Add some space around the indicator
          child: SizedBox(
            height: 18, // Control the size of the spinner
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        )
            : Text(
          'Login',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      TextButton(
        onPressed: () => {
          viewModel.setApiKeyPreference(false)
        },
        child: Text(
          "Login with Dawarich account",
          style: Theme.of(context).textTheme.bodySmall,
        )
      )
    ];
  }


  List<Widget> _getFormContent(BuildContext context, ConnectViewModel viewModel) {
    if (viewModel.hostVerified) {
      return viewModel.apiKeyPreferred
          ? _apiKeyLoginFormContent(context, viewModel)
          : _loginFormContent(context, viewModel);
    }
    return _hostFormContent(context, viewModel);
  }

  Widget _formBase(BuildContext context) {
    final ConnectViewModel viewModel = Provider.of<ConnectViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.snackbarMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.snackbarMessage!)),
        );
        viewModel.clearSnackbarMessage();
      }
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _getFormContent(context, viewModel)
    );
  }

  Widget _pageContent(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: _formBase(context)
        )
    );
  }

  Widget _pageBase(BuildContext context) {
    return Scaffold(
        appBar: const Appbar(
          title: "Connect to Dawarich",
          fontSize: 28,
        ),
        body: _pageContent(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ConnectViewModel>(),
      child: Builder(builder: (context) => _pageBase(context)),
    );
  }
}