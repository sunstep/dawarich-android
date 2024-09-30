import 'package:flutter/material.dart';
import 'package:dawarich/presentation/widgets/appbar.dart';
import 'package:dawarich/presentation/widgets/drawer.dart';

class ExportsPage extends StatefulWidget {

  const ExportsPage({super.key});

  @override
  ExportsPageState createState() => ExportsPageState();
}

class ExportsPageState extends State<ExportsPage> {

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(
        title: "Exports",
        fontSize: 40,
      ),
      body: _pageContent(),
      drawer: const CustomDrawer()
    );
  }

  Widget _pageContent(){
    return Container();
  }
}