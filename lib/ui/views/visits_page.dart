import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:dawarich/ui/widgets/appbar.dart';

class VisitsPage extends StatefulWidget {

  const VisitsPage({super.key});

  @override
  VisitsPageState createState() => VisitsPageState();
}

class VisitsPageState extends State<VisitsPage> {


  Widget _pageContent() {
    return Container();
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Visits", fontSize: 40),
      body: _pageContent(),
      drawer: const CustomDrawer(),
    );
  }
}