import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:dawarich/core/shell/drawer/drawer.dart';

@RoutePage()
class SettingsView extends StatelessWidget {

  const SettingsView({super.key});

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "Settings", titleFontSize: 40),
      body: _pageContent(context),
      drawer: CustomDrawer(),
    );
  }

  Widget _pageContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
