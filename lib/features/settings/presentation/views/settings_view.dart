import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/shared/widgets/app_scaffold.dart';
import 'package:dawarich/core/shell/drawer/drawer.dart';

@RoutePage()
class SettingsView extends StatelessWidget {

  const SettingsView({super.key});

  @override
  build(BuildContext context) {
    return AppScaffold(
      title: "Settings",
      titleFontSize: 40,
      drawer: CustomDrawer(),
      body: _pageContent(context),
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
