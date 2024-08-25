import 'package:flutter/material.dart';
import 'package:dawarich/widgets/appbar.dart';
import 'package:dawarich/widgets/drawer.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {

  @override
  build(BuildContext context){
    return Scaffold(
      appBar: const Appbar(
          title: "Settings",
          fontSize: 40),
      body: _pageContent(),
      drawer: const CustomDrawer(),
    );
  }

  Widget _pageContent() {
    return Container();
  }


}