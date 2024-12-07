import 'package:dawarich/application/dependency_injection/service_locator.dart';
import 'package:dawarich/ui/models/connect_page_viewmodel.dart';
import 'package:dawarich/ui/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:provider/provider.dart';

class ConnectionPage extends StatelessWidget {

  ConnectionPage({super.key});

  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _apiController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Widget> _formContent(BuildContext context, ConnectViewModel viewModel) {
    return [
      TextFormField(
          controller: _hostController,
          decoration: const InputDecoration(
            labelText: 'Host',
          ).applyDefaults(Theme
              .of(context)
              .inputDecorationTheme),
          keyboardType: TextInputType.url,
          validator: (value) => viewModel.validateInputs(value),
          forceErrorText: viewModel.credentialsError,
          cursorColor: Theme
              .of(context)
              .brightness == Brightness.dark
              ? Colors.white
              : Colors.black
      ),
      const SizedBox(height: 16),
      TextFormField(
          controller: _apiController,
          decoration: const InputDecoration(
            labelText: 'Api Key',
          ).applyDefaults(Theme
              .of(context)
              .inputDecorationTheme),
          keyboardType: TextInputType.visiblePassword,
          validator: (value) => viewModel.validateInputs(value),
          forceErrorText: viewModel.credentialsError,
          cursorColor: Theme
              .of(context)
              .brightness == Brightness.dark
              ? Colors.white
              : Colors.black
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        style: Theme
            .of(context)
            .elevatedButtonTheme
            .style,
        onPressed: viewModel.isValidating
            ? null
            : () =>
            viewModel.connect(
              _hostController.text,
              _apiController.text,
            ),
        child: viewModel.isValidating
            ? const CircularProgressIndicator()
            : Text(
          'Connect',
          style: Theme
              .of(context)
              .textTheme
              .bodySmall,
        ),
      ),
    ];
  }


  Widget _formBase(BuildContext context) {
    final ConnectViewModel viewModel = Provider.of<ConnectViewModel>(context);
    viewModel.setNavigatorFunction(() {
      Navigator.pushReplacementNamed(context, AppRouter.map);
    });
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _formContent(context, viewModel)
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
          fontSize: 40,
        ),
        body: _pageContent(context),
        drawer: const CustomDrawer()
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ConnectViewModel>(),
      child: _pageBase(context),
    );
  }
}