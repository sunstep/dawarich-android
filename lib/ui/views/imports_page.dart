import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/custom_appbar.dart';
import 'package:dawarich/ui/widgets/drawer.dart';

final class ImportsPage extends StatefulWidget {
  const ImportsPage({super.key});

  @override
  ImportsPageState createState() => ImportsPageState();
}

final class ImportsPageState extends State<ImportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "Imports",
        titleFontSize: 40,
      ),
      body: _pageContent(),
      drawer: const CustomDrawer(),
    );
  }

  Widget _pageContent() {
    return const Scaffold();
  }
}
