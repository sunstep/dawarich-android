import 'package:flutter/material.dart';
import 'package:dawarich/widgets/appbar.dart';
import 'package:dawarich/containers/connect.dart';
import 'package:dawarich/pages/map_page.dart';

class ConnectionPage extends StatefulWidget {

  const ConnectionPage({super.key});

  @override
  ConnectionPageState createState() => ConnectionPageState();
}

class ConnectionPageState extends State<ConnectionPage> {

  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _apiController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isValidating = false;
  String? _credentialsError;
  late ConnectContainer _connect;

  @override
  void initState(){
    super.initState();
    _connect = ConnectContainer(context);
  }

  void connect() async {

    if (!_formKey.currentState!.validate()){
      return;
    }

    setState(() {
      _isValidating = true;
      _credentialsError = null;
    });

    bool isValid = await _connect.validateCredentials(_hostController.text, _apiController.text);

    setState(() {

      if (isValid) {
        _credentialsError = null;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MapPage()));
      } else {

        _credentialsError = 'Invalid host or API key';
      }

      _isValidating = false;
    });
  }

  Widget _pageContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host',
              ).applyDefaults(Theme.of(context).inputDecorationTheme),
              keyboardType: TextInputType.url,
              validator: (value) => _connect.validateInputs(value),
              forceErrorText: _credentialsError,
              cursorColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiController,
              decoration: const InputDecoration(
                labelText: 'Api Key',
              ).applyDefaults(Theme.of(context).inputDecorationTheme),
              keyboardType: TextInputType.visiblePassword,
              validator: (value) => _connect.validateInputs(value),
              forceErrorText: _credentialsError,
              cursorColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: connect,
              child: _isValidating
                ? const CircularProgressIndicator()
                  : Text(
                'Connect',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Connect to Dawarich", fontSize: 35),
      body: _pageContent(),
    );
  }
}
