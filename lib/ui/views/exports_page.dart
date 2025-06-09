import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/custom_appbar.dart';
import 'package:dawarich/ui/widgets/drawer.dart';

final class ExportsPage extends StatefulWidget {
  const ExportsPage({super.key});

  @override
  ExportsPageState createState() => ExportsPageState();
}

final class ExportsPageState extends State<ExportsPage> {
  @override
  build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppbar(
          title: "Exports",
          titleFontSize: 40,
        ),
        body: _pageContent(),
        drawer: const CustomDrawer());
  }

  Widget _pageContent() {
    return Container();
  }
}
