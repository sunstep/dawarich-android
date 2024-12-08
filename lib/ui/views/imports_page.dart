import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:dawarich/ui/widgets/drawer.dart';

class ImportsPage extends StatefulWidget {

  const ImportsPage({super.key});

  @override
  ImportsPageState createState() => ImportsPageState();
}

class ImportsPageState extends State<ImportsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(
        title: "Imports",
        fontSize: 40,
      ),
      body: _pageContent(),
      drawer: const CustomDrawer(),
    );
  }

  Widget _pageContent(){
    return const Scaffold(

    );
  }
}