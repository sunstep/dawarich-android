import 'package:flutter/material.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:dawarich/core/shell/drawer/drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
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
