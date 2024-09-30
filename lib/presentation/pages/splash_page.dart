import "package:flutter/material.dart";
import 'package:dawarich/presentation/routing/app_router.dart';
import 'package:dawarich/helpers/endpoint.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';

class SplashPage extends StatefulWidget {

  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final endpoint = Provider.of<EndpointResult>(context, listen: false);

    await endpoint.getInfo();
    await _getLoginState();
  }

  @override
  Widget build(BuildContext context){
    return const Scaffold();
  }

  Future<void> _getLoginState() async {

    EndpointResult endpoint = Provider.of<EndpointResult>(context, listen: false);

    String? host = endpoint.endPoint;
    String? apiKey = endpoint.apiKey;

    try {
      final uri = Uri.parse('$host/api/v1/points/?api_key=$apiKey&end_at=0000-01-01');
      final response = await get(uri);

      if (!mounted){
        return;
      }

      if (response.statusCode == 200) {

        Navigator.of(context).pushReplacementNamed(AppRouter.map);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRouter.connect);
      }
    } catch (e) {

      if (!mounted){
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRouter.connect);
    }


  }
}
