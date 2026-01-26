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
      body: _pageContent(),
      drawer: CustomDrawer(),
    );
  }

  Widget _pageContent() {
    return Container();
  }
}
